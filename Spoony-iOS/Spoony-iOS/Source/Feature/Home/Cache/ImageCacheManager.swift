//
//  ImageCacheManager.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 3/3/25.
//

import SwiftUI

actor ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private let cacheExpirationTime: TimeInterval = 7 * 24 * 60 * 60 // 1주일
    private var cleanupTask: Task<Void, Never>?
    
    private init() {
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let imageCachePath = cachePath.appending("/ImageCache")
        cacheDirectory = URL(fileURLWithPath: imageCachePath)
        createCacheDirectoryIfNeeded()
        scheduleCleanup()
    }
    
    deinit {
        cleanupTask?.cancel()
    }
    
    private func scheduleCleanup() {
        cleanupTask?.cancel()
        cleanupTask = Task.detached(priority: .background) {
            await self.cleanExpiredCache()
        }
    }
    
    private func createCacheDirectoryIfNeeded() {
        guard !fileManager.fileExists(atPath: cacheDirectory.path) else { return }
        
        do {
            try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        } catch {
            print("Error creating cache directory: \(error)")
        }
    }
    
    func getImageFromMemory(for url: String) -> UIImage? {
        return memoryCache.object(forKey: url as NSString)
    }
    
    func getImageFromDisk(for url: String) async -> UIImage? {
        let fileURL = cacheFileURL(for: url)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        do {
            let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
            if let modificationDate = attributes[.modificationDate] as? Date {
                if Date().timeIntervalSince(modificationDate) > self.cacheExpirationTime {
                    try? fileManager.removeItem(at: fileURL)
                    return nil
                }
            }
            
            let data = try Data(contentsOf: fileURL)
            if let image = UIImage(data: data) {
                saveImageToMemory(image, for: url)
                return image
            }
        } catch {
            print("Error reading image from disk: \(error)")
        }
        
        return nil
    }
    
    func saveImageToMemory(_ image: UIImage, for url: String) {
        let cost = Int(image.size.width * image.size.height * 4)
        memoryCache.setObject(image, forKey: url as NSString, cost: cost)
    }
    
    func saveImageToDisk(_ image: UIImage, for url: String) async {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        
        let fileURL = cacheFileURL(for: url)
        
        do {
            try data.write(to: fileURL)
        } catch {
            print("Error saving image to disk: \(error)")
        }
    }
    
    private func cacheFileURL(for url: String) -> URL {
        // URL에 허용되지 않는 문자 대체
        let filename = url.replacingOccurrences(of: "/", with: "_")
                         .replacingOccurrences(of: ":", with: "_")
                         .replacingOccurrences(of: "?", with: "_")
                         .replacingOccurrences(of: "&", with: "_")
                         .replacingOccurrences(of: "=", with: "_")
        
        return cacheDirectory.appendingPathComponent(filename)
    }
    
    func cleanExpiredCache() async {
        do {
            try Task.checkCancellation()
            
            let resourceKeys: [URLResourceKey] = [.contentModificationDateKey]
            let fileURLs = try fileManager.contentsOfDirectory(at: cacheDirectory,
                                                            includingPropertiesForKeys: resourceKeys)
            
            let now = Date()
            
            for fileURL in fileURLs {
                try Task.checkCancellation()
                
                guard let resourceValues = try? fileURL.resourceValues(forKeys: Set(resourceKeys)),
                      let modificationDate = resourceValues.contentModificationDate else {
                    continue
                }
                
                if now.timeIntervalSince(modificationDate) > self.cacheExpirationTime {
                    try? fileManager.removeItem(at: fileURL)
                }
            }
        } catch is CancellationError {
            return
        } catch {
            print("Error cleaning expired cache: \(error)")
        }
    }
    
    func clearAllCache() async {
        memoryCache.removeAllObjects()
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: cacheDirectory,
                                                           includingPropertiesForKeys: nil)
            for fileURL in contents {
                try? fileManager.removeItem(at: fileURL)
            }
        } catch {
            print("Error clearing disk cache: \(error)")
        }
    }
}

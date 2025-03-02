//
//  ImageCacheManager.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 3/3/25.
//

import SwiftUI


final class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private let cacheExpirationTime: TimeInterval = 7 * 24 * 60 * 60
    
    private let diskIOQueue = DispatchQueue(label: "com.spoony.imagecache.diskio", qos: .utility)
    
    private init() {
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 50 * 1024 * 1024
        
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let imageCachePath = cachePath.appending("/ImageCache")
        cacheDirectory = URL(fileURLWithPath: imageCachePath)
        
        createCacheDirectoryIfNeeded()
        cleanExpiredCache()
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
    
    func getImageFromDisk(for url: String) -> UIImage? {
        let fileURL = cacheFileURL(for: url)
        
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        
        do {
            let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
            if let modificationDate = attributes[.modificationDate] as? Date {
                if Date().timeIntervalSince(modificationDate) > cacheExpirationTime {
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
    
    func saveImageToDisk(_ image: UIImage, for url: String) {
        diskIOQueue.async { [weak self] in
            guard let self = self,
                  let data = image.jpegData(compressionQuality: 0.8) else { return }
            
            let fileURL = self.cacheFileURL(for: url)
            
            do {
                try data.write(to: fileURL)
            } catch {
                print("Error saving image to disk: \(error)")
            }
        }
    }
    
    private func cacheFileURL(for url: String) -> URL {
        let filename = url.replacingOccurrences(of: "/", with: "_")
                         .replacingOccurrences(of: ":", with: "_")
                         .replacingOccurrences(of: "?", with: "_")
                         .replacingOccurrences(of: "&", with: "_")
                         .replacingOccurrences(of: "=", with: "_")
        
        return cacheDirectory.appendingPathComponent(filename)
    }
    
    func cleanExpiredCache() {
        diskIOQueue.async { [weak self] in
            guard let self = self else { return }
            
            do {
                let resourceKeys: [URLResourceKey] = [.contentModificationDateKey]
                let fileURLs = try self.fileManager.contentsOfDirectory(at: self.cacheDirectory,
                                                                       includingPropertiesForKeys: resourceKeys)
                
                let now = Date()
                
                for fileURL in fileURLs {
                    guard let resourceValues = try? fileURL.resourceValues(forKeys: Set(resourceKeys)),
                          let modificationDate = resourceValues.contentModificationDate else {
                        continue
                    }
                    
                    if now.timeIntervalSince(modificationDate) > self.cacheExpirationTime {
                        try? self.fileManager.removeItem(at: fileURL)
                    }
                }
            } catch {
                print("Error cleaning expired cache: \(error)")
            }
        }
    }
    
    func clearAllCache() {
        memoryCache.removeAllObjects()
        
        diskIOQueue.async { [weak self] in
            guard let self = self else { return }
            
            do {
                let contents = try self.fileManager.contentsOfDirectory(at: self.cacheDirectory,
                                                                       includingPropertiesForKeys: nil)
                for fileURL in contents {
                    try self.fileManager.removeItem(at: fileURL)
                }
            } catch {
                print("Error clearing disk cache: \(error)")
            }
        }
    }
}

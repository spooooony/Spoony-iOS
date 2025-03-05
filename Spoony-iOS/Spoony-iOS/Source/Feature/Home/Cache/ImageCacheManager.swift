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
    
    private let cacheExpirationTime: TimeInterval = 7 * 24 * 60 * 60
    
    private init() {
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 50 * 1024 * 1024
        
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let imageCachePath = cachePath.appending("/ImageCache")
        cacheDirectory = URL(fileURLWithPath: imageCachePath)
        
        createCacheDirectoryIfNeeded()
        
        Task.detached(priority: .background) {
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
        return await Task.detached(priority: .background) {
            let fileURL = await self.cacheFileURL(for: url)
            
            guard self.fileManager.fileExists(atPath: fileURL.path) else { return nil }
            
            do {
                let attributes = try self.fileManager.attributesOfItem(atPath: fileURL.path)
                if let modificationDate = attributes[.modificationDate] as? Date {
                    if Date().timeIntervalSince(modificationDate) > self.cacheExpirationTime {
                        try? self.fileManager.removeItem(at: fileURL)
                        return nil
                    }
                }
                
                let data = try Data(contentsOf: fileURL)
                if let image = UIImage(data: data) {
                    await self.saveImageToMemory(image, for: url)
                    return image
                }
            } catch {
                print("Error reading image from disk: \(error)")
            }
            
            return nil
        }.value
    }
    
    func saveImageToMemory(_ image: UIImage, for url: String) {
        let cost = Int(image.size.width * image.size.height * 4)
        memoryCache.setObject(image, forKey: url as NSString, cost: cost)
    }
    
    func saveImageToDisk(_ image: UIImage, for url: String) async {
        await Task.detached(priority: .background) {
            guard let data = image.jpegData(compressionQuality: 0.8) else { return }
            
            let fileURL = await self.cacheFileURL(for: url)
            
            do {
                try data.write(to: fileURL)
            } catch {
                print("Error saving image to disk: \(error)")
            }
        }.value
    }
    
    private func cacheFileURL(for url: String) -> URL {
        let filename = url.replacingOccurrences(of: "/", with: "_")
                         .replacingOccurrences(of: ":", with: "_")
                         .replacingOccurrences(of: "?", with: "_")
                         .replacingOccurrences(of: "&", with: "_")
                         .replacingOccurrences(of: "=", with: "_")
        
        return cacheDirectory.appendingPathComponent(filename)
    }
    
    func cleanExpiredCache() async {
        await Task.detached(priority: .background) {
            do {
                let resourceKeys: [URLResourceKey] = [.contentModificationDateKey]
                let fileURLs = try await self.fileManager.contentsOfDirectory(at: self.cacheDirectory,
                                                                includingPropertiesForKeys: resourceKeys)
                
                let now = Date()
                
                for fileURL in fileURLs {
                    guard let resourceValues = try? fileURL.resourceValues(forKeys: Set(resourceKeys)),
                          let modificationDate = resourceValues.contentModificationDate else {
                        continue
                    }
                    
                    if now.timeIntervalSince(modificationDate) > self.cacheExpirationTime {
                        try? await self.fileManager.removeItem(at: fileURL)
                    }
                }
            } catch {
                print("Error cleaning expired cache: \(error)")
            }
        }.value
    }
    
    func clearAllCache() async {
        memoryCache.removeAllObjects()
        
        await Task.detached(priority: .background) {
            do {
                let contents = try await self.fileManager.contentsOfDirectory(at: self.cacheDirectory,
                                                               includingPropertiesForKeys: nil)
                for fileURL in contents {
                    try await self.fileManager.removeItem(at: fileURL)
                }
            } catch {
                print("Error clearing disk cache: \(error)")
            }
        }.value
    }
}

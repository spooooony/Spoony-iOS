//
//  ImageChaes.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 3/2/25.
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

class CachedImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var url: URL?
    private var task: URLSessionDataTask?
    private var isLoading = false
    
    init(url: URL?) {
        self.url = url
    }
    
    func load() {
        guard !isLoading, let url = url else { return }
        
        if let cachedImage = ImageCacheManager.shared.getImageFromMemory(for: url.absoluteString) {
            self.image = cachedImage
            return
        }
        
        if let diskCachedImage = ImageCacheManager.shared.getImageFromDisk(for: url.absoluteString) {
            self.image = diskCachedImage
            return
        }
        
        isLoading = true
        
        task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            defer {
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
            }
            
            guard let self = self,
                  let data = data,
                  error == nil,
                  let image = UIImage(data: data) else {
                return
            }
            
            ImageCacheManager.shared.saveImageToMemory(image, for: url.absoluteString)
            ImageCacheManager.shared.saveImageToDisk(image, for: url.absoluteString)
            
            DispatchQueue.main.async {
                self.image = image
            }
        }
        
        task?.resume()
    }
    
    func cancel() {
        task?.cancel()
        isLoading = false
    }
}

class ImagePrefetchManager {
    static let shared = ImagePrefetchManager()
    
    private let prefetchQueue = OperationQueue()
    private var prefetchingURLs = Set<String>()
    private let lock = NSLock()
    
    private var scrollDirection: ScrollDirection = .none
    private var lastContentOffset: CGFloat = 0
    
    enum ScrollDirection {
        case up, down, none
    }
    
    private init() {
        prefetchQueue.maxConcurrentOperationCount = 2
    }
    
    func prefetchImagesAround(visibleItems: [String], allItems: [String]) {
        lock.lock()
        defer { lock.unlock() }
        
        let direction = scrollDirection
        
        guard !visibleItems.isEmpty, !allItems.isEmpty else { return }
        
        guard let lastVisibleItem = visibleItems.last,
              let lastVisibleIndex = allItems.firstIndex(of: lastVisibleItem) else {
            return
        }
        
        var itemsToPrefetch: [String] = []
        
        switch direction {
        case .down:
            let endIndex = min(lastVisibleIndex + 5, allItems.count - 1)
            if lastVisibleIndex < endIndex {
                itemsToPrefetch = Array(allItems[lastVisibleIndex + 1...endIndex])
            }
        case .up:
            if let firstVisibleItem = visibleItems.first,
               let firstVisibleIndex = allItems.firstIndex(of: firstVisibleItem),
               firstVisibleIndex > 0 {
                let startIndex = max(0, firstVisibleIndex - 3)
                itemsToPrefetch = Array(allItems[startIndex..<firstVisibleIndex])
            }
        case .none:
            let endIndex = min(lastVisibleIndex + 3, allItems.count - 1)
            if lastVisibleIndex < endIndex {
                itemsToPrefetch = Array(allItems[lastVisibleIndex + 1...endIndex])
            }
        }
        
        prefetchImages(urls: itemsToPrefetch)
    }
    
    func updateScrollDirection(currentOffset: CGFloat) {
        if currentOffset > lastContentOffset {
            scrollDirection = .down
        } else if currentOffset < lastContentOffset {
            scrollDirection = .up
        }
        
        lastContentOffset = currentOffset
    }
    
    func prefetchImages(urls: [String]) {
        for urlString in urls {
            guard !prefetchingURLs.contains(urlString),
                  ImageCacheManager.shared.getImageFromMemory(for: urlString) == nil,
                  ImageCacheManager.shared.getImageFromDisk(for: urlString) == nil,
                  let url = URL(string: urlString) else {
                continue
            }
            
            prefetchingURLs.insert(urlString)
            
            prefetchQueue.addOperation { [weak self] in
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    defer {
                        DispatchQueue.main.async {
                            self?.lock.lock()
                            self?.prefetchingURLs.remove(urlString)
                            self?.lock.unlock()
                        }
                    }
                    
                    guard let data = data, error == nil, let image = UIImage(data: data) else { return }
                    
                    ImageCacheManager.shared.saveImageToMemory(image, for: urlString)
                    ImageCacheManager.shared.saveImageToDisk(image, for: urlString)
                }
                task.resume()
            }
        }
    }
    
    func cancelAllPrefetching() {
        prefetchQueue.cancelAllOperations()
        lock.lock()
        prefetchingURLs.removeAll()
        lock.unlock()
    }
}

struct CachedImage<Placeholder: View>: View {
    @StateObject private var loader: CachedImageLoader
    private let placeholder: () -> Placeholder
    
    init(url: String?, @ViewBuilder placeholder: @escaping () -> Placeholder) {
        self.placeholder = placeholder
        _loader = StateObject(wrappedValue: CachedImageLoader(url: URL(string: url ?? "")))
    }
    
    var body: some View {
        content
            .onAppear(perform: loader.load)
            .onDisappear(perform: loader.cancel)
    }
    
    private var content: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                placeholder()
            }
        }
    }
}

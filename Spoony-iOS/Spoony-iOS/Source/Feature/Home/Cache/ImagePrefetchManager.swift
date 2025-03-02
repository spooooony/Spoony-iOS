//
//  ImagePrefetchManager.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 3/3/25.
//

import SwiftUI

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

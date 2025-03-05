//
//  CachedImageLoader.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 3/3/25.
//

import SwiftUI

class CachedImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var url: URL?
    private var task: Task<Void, Never>?
    @Published private(set) var isLoading = false
    @Published private(set) var loadError: Error?
    
    init(url: URL?) {
        self.url = url
    }
    
    func load() {
        guard !isLoading, let url = url else { return }
        
        // 이전 작업 취소 - 중복 요청 방지
        cancel()
        loadError = nil
        isLoading = true
        
        task = Task { @MainActor in
            do {
                if let cachedImage = await ImageCacheManager.shared.getImageFromMemory(for: url.absoluteString) {
                    if !Task.isCancelled {
                        self.image = cachedImage
                        self.isLoading = false
                    }
                    return
                }
                
                if let diskCachedImage = await ImageCacheManager.shared.getImageFromDisk(for: url.absoluteString) {
                    if !Task.isCancelled {
                        self.image = diskCachedImage
                        self.isLoading = false
                    }
                    return
                }
                
                let (data, _) = try await URLSession.shared.data(from: url)
                
                guard !Task.isCancelled else {
                    self.isLoading = false
                    return
                }
                
                if let downloadedImage = UIImage(data: data) {
                    await ImageCacheManager.shared.saveImageToMemory(downloadedImage, for: url.absoluteString)
                    await ImageCacheManager.shared.saveImageToDisk(downloadedImage, for: url.absoluteString)
                    
                    if !Task.isCancelled {
                        self.image = downloadedImage
                    }
                } else {
                    throw NSError(domain: "CachedImageLoader", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
                }
            } catch {
                if !Task.isCancelled {
                    if (error as NSError).code != NSURLErrorCancelled {
                        self.loadError = error
                        print("Error downloading image: \(error)")
                    }
                }
            }
            
            if !Task.isCancelled {
                self.isLoading = false
            }
        }
    }
    
    func cancel() {
        task?.cancel()
        task = nil
        isLoading = false
    }
    
    deinit {
        cancel()
    }
}

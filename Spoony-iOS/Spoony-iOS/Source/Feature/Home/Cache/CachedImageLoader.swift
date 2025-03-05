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
    private var isLoading = false
    
    init(url: URL?) {
        self.url = url
    }
    
    func load() {
        guard !isLoading, let url = url else { return }
        
        isLoading = true
        
        task = Task { @MainActor in
            if let cachedImage = await ImageCacheManager.shared.getImageFromMemory(for: url.absoluteString) {
                self.image = cachedImage
                self.isLoading = false
                return
            }
            
            if let diskCachedImage = await ImageCacheManager.shared.getImageFromDisk(for: url.absoluteString) {
                self.image = diskCachedImage
                self.isLoading = false
                return
            }
            
            do {
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
                }
            } catch {
                if (error as NSError).code != NSURLErrorCancelled {
                    print("Error downloading image: \(error)")
                }
            }
            
            self.isLoading = false
        }
    }
    
    func cancel() {
        task?.cancel()
        isLoading = false
    }
    
    deinit {
        cancel()
    }
}

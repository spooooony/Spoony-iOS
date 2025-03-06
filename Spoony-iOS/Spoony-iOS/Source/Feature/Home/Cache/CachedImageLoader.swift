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
    private var loadTask: Task<Void, Never>?
    
    @Published private(set) var isLoading = false
    @Published private(set) var loadError: Error?
    
    init(url: URL?) {
        self.url = url
    }
    
    func load() async {
        guard !isLoading, let url = url else { return }
        
        loadTask?.cancel()
        
        loadError = nil
        isLoading = true
        
        loadTask = Task {
            do {
                if let cachedImage = await ImageCacheManager.shared.getImageFromMemory(for: url.absoluteString) {
                    if !Task.isCancelled {
                        self.image = cachedImage
                    }
                    return
                }
                
                if let diskCachedImage = try await withCheckedThrowingContinuation({ continuation in
                    Task {
                        let image = await ImageCacheManager.shared.getImageFromDisk(for: url.absoluteString)
                        continuation.resume(returning: image)
                    }
                }) {
                    if !Task.isCancelled {
                        self.image = diskCachedImage
                    }
                    return
                }
                
                let imageData = try await withTaskCancellationHandler {
                    try await URLSession.shared.data(from: url).0
                } onCancel: {
                    // 취소 처리 - URLSession 태스크는 자동으로 취소
                }
                
                guard !Task.isCancelled else { return }
                
                if let downloadedImage = UIImage(data: imageData) {
                    await ImageCacheManager.shared.saveImageToMemory(downloadedImage, for: url.absoluteString)
                    await ImageCacheManager.shared.saveImageToDisk(downloadedImage, for: url.absoluteString)
                    
                    if !Task.isCancelled {
                        self.image = downloadedImage
                    }
                } else {
                    throw NSError(domain: "CachedImageLoader", code: -1,
                                 userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
                }
            } catch {
                if !Task.isCancelled {
                    if let urlError = error as? URLError, urlError.code == .cancelled {
                    } else {
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
    
    func cancelLoad() {
        loadTask?.cancel()
        loadTask = nil
        if isLoading {
            isLoading = false
        }
    }
    
    deinit {
        cancelLoad()
    }
}

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
        
        await MainActor.run {
            self.loadError = nil
            self.isLoading = true
        }
        
        loadTask = Task { [weak self] in
            guard let self = self else { return }
            
            do {
                if let cachedImage = await ImageCacheManager.shared.getImageFromMemory(for: url.absoluteString) {
                    if !Task.isCancelled {
                        await MainActor.run {
                            self.image = cachedImage
                            self.isLoading = false
                        }
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
                        await MainActor.run {
                            self.image = diskCachedImage
                            self.isLoading = false
                        }
                    }
                    return
                }
                
                let imageData = try await URLSession.shared.data(from: url).0
                
                guard !Task.isCancelled else { return }
                
                if let downloadedImage = UIImage(data: imageData) {
                    await ImageCacheManager.shared.saveImageToMemory(downloadedImage, for: url.absoluteString)
                    await ImageCacheManager.shared.saveImageToDisk(downloadedImage, for: url.absoluteString)
                    
                    if !Task.isCancelled {
                        await MainActor.run {
                            self.image = downloadedImage
                            self.isLoading = false
                        }
                    }
                } else {
                    if !Task.isCancelled {
                        await MainActor.run {
                            self.loadError = APIError.decodingError
                            self.isLoading = false
                        }
                    }
                }
            } catch {
                if !Task.isCancelled {
                    if let urlError = error as? URLError, urlError.code == .cancelled {
                    } else {
                        await MainActor.run {
                            self.loadError = error
                            self.isLoading = false
                        }
                        print("Error downloading image: \(error)")
                    }
                }
            }
        }
    }
    
    func cancelLoad() {
        loadTask?.cancel()
        loadTask = nil
        
        if isLoading {
            Task { @MainActor [weak self] in
                self?.isLoading = false
            }
        }
    }
    
    deinit {
        cancelLoad()
    }
}

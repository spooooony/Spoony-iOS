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
        
        task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            defer {
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
            }
            
            guard let data = data,
                  error == nil,
                  let image = UIImage(data: data) else {
                return
            }
            
            ImageCacheManager.shared.saveImageToMemory(image, for: url.absoluteString)
            ImageCacheManager.shared.saveImageToDisk(image, for: url.absoluteString)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
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

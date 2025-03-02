//
//  ImageChaes.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 3/2/25.
//

import Foundation
import SwiftUI

class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private init() {}
    
    private var cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 100
        return cache
    }()
    
    func add(image: UIImage, url: String) {
        cache.setObject(image, forKey: url as NSString)
    }
    
    func get(url: String) -> UIImage? {
        return cache.object(forKey: url as NSString)
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var task: URLSessionDataTask?
    private var url: URL?
    private var isLoading = false
    
    init(url: URL?) {
        self.url = url
    }
    
    func load() {
        guard !isLoading else { return }
        guard let url = url else { return }
        
        if let cachedImage = ImageCacheManager.shared.get(url: url.absoluteString) {
            self.image = cachedImage
            return
        }
        
        isLoading = true
        
        task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  error == nil,
                  let loadedImage = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
                return
            }
            
            ImageCacheManager.shared.add(image: loadedImage, url: url.absoluteString)
            
            DispatchQueue.main.async {
                self.image = loadedImage
                self.isLoading = false
            }
        }
        task?.resume()
    }
    
    func cancel() {
        task?.cancel()
        isLoading = false
    }
}

struct CachedImage<Placeholder: View>: View {
    @StateObject private var loader: ImageLoader
    private let placeholder: () -> Placeholder
    
    init(url: String?, @ViewBuilder placeholder: @escaping () -> Placeholder) {
        self.placeholder = placeholder
        _loader = StateObject(wrappedValue: ImageLoader(url: URL(string: url ?? "")))
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

struct CachedImageView: View {
    let url: String
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        CachedImage(url: url) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.1))
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

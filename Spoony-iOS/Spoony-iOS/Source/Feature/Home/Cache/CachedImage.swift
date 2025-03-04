//
//  CachedImage.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 3/2/25.
//

import SwiftUI

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

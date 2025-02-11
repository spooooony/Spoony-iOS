//
//  PlaceDetailCard.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/15/25.
//

import SwiftUI

struct PlaceImagesLayout: View {
    let images: [String]
    
    private var limitedImages: [String] {
        Array(images.prefix(3))
    }
    
    var body: some View {
        HStack(spacing: 1) {
            switch limitedImages.count {
            case 1:
                imageView(
                    urlString: limitedImages[0],
                    width: nil,
                    height: 108.adjusted,
                    corners: [.topLeft, .topRight]
                )
            case 2:
                ForEach(0..<2, id: \.self) { index in
                    imageView(
                        urlString: limitedImages[index],
                        width: nil,
                        height: 108.adjusted,
                        corners: index == 0 ? [.topLeft] : [.topRight]
                    )
                    .frame(maxWidth: .infinity)
                }
            case 3:
                ForEach(0..<3, id: \.self) { index in
                    imageView(
                        urlString: limitedImages[index],
                        width: 108.adjusted,
                        height: 108.adjusted,
                        corners: index == 0 ? [.topLeft] : (index == 2 ? [.topRight] : [])
                    )
                }
            default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 108.adjusted)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .mask(
                    RoundedCorner(radius: 10, corners: [.topLeft, .topRight])
                )
        )
    }
    
    private func imageView(urlString: String, width: CGFloat?, height: CGFloat, corners: UIRectCorner) -> some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                Color.gray
             
            default:
                Color.gray
            }
        }
        .frame(width: width, height: height)
        .frame(maxWidth: width == nil ? .infinity : nil)
        .clipped()
        .mask(
            RoundedCorner(radius: 10, corners: corners)
        )
    }
}

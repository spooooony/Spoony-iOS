//
//  PlaceDetailCard.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/15/25.
//

import SwiftUI

struct PlaceImagesLayout: View {
    let images: [String]
    
    var body: some View {
        HStack(spacing: 1) {
            switch images.count {
            case 1:
                imageView(
                    urlString: images[0],
                    width: nil,
                    height: 132.adjusted,
                    corners: [.topLeft, .topRight]
                )
            case 2:
                ForEach(0..<2, id: \.self) { index in
                    imageView(
                        urlString: images[index],
                        width: nil,
                        height: 132.adjusted,
                        corners: index == 0 ? [.topLeft] : [.topRight]
                    )
                    .frame(maxWidth: .infinity)
                }
            case 3:
                ForEach(0..<3, id: \.self) { index in
                    imageView(
                        urlString: images[index],
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
        .frame(height: images.count == 3 ? 108.adjusted : 132.adjusted)
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
            @unknown default:
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

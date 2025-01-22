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
                if let url = URL(string: images[0]) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure(_):
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        case .empty:
                            ProgressView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 132.adjusted)
                    .clipShape(RoundedCorner(radius: 12, corners: [.topLeft, .topRight]))
                }
                
            case 2:
                ForEach(0..<2, id: \.self) { index in
                    if let url = URL(string: images[index]) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure(_):
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            case .empty:
                                ProgressView()
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 132.adjusted)
                        .clipShape(
                            RoundedCorner(
                                radius: 12,
                                corners: index == 0 ? [.topLeft] : [.topRight]
                            )
                        )
                    }
                }
                
            case 3:
                ForEach(0..<3, id: \.self) { index in
                    if let url = URL(string: images[index]) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure(_):
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            case .empty:
                                ProgressView()
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 132.adjusted)
                        .clipShape(
                            RoundedCorner(
                                radius: 12,
                                corners: index == 0 ? [.topLeft] : (index == 2 ? [.topRight] : [])
                            )
                        )
                    }
                }
                
            default:
                EmptyView()
            }
        }
    }
}

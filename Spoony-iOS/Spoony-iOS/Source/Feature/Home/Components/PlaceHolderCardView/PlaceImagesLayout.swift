//
//  PlaceDetailCard.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/15/25.
//

import SwiftUI

struct PlaceImagesLayout: View {
    let images: [String]
    let containerHeight: CGFloat
    
    var body: some View {
        HStack(spacing: 1) {
            switch images.count {
            case 1:
                Image(images[0])
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: containerHeight * 0.35) //비율이라 adjust X
                    .clipShape(RoundedCorner(radius: 12, corners: [.topLeft, .topRight]))
                
            case 2:
                ForEach(0..<2, id: \.self) { index in
                    Image(images[index])
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: containerHeight * 0.35)
                        .clipShape(
                            RoundedCorner(
                                radius: 12,
                                corners: index == 0 ? [.topLeft] : [.topRight]
                            )
                        )
                }
                
            case 3:
                ForEach(0..<3, id: \.self) { index in
                    Image(images[index])
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: containerHeight * 0.35)
                        .clipShape(
                            RoundedCorner(
                                radius: 12,
                                corners: index == 0 ? [.topLeft] : (index == 2 ? [.topRight] : [])
                            )
                        )
                }
                
            default:
                EmptyView()
            }
        }
    }
}


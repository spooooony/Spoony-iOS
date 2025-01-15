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
                Image(images[0])
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 132)
                    .clipShape(RoundedCorner(radius: 12, corners: [.topLeft, .topRight]))
                
            case 2:
                ForEach(0..<2, id: \.self) { index in
                    Image(images[index])
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 132)
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
                        .frame(height: 132)
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

#Preview {
    PlaceCardsContainer(places: [
        CardPlace(
            name: "스타벅스",
            visitorCount: "45",
            address: "서울특별시 마포구 어울마당로",
            images: ["testImage1", "testImage2", "testImage3"],
            title: "클레오가트라",
            subTitle: "성동구 수제",
            description: "포켓몬 중 하나의 이름을 가졌지만 카페에요"
        ),
        CardPlace(
            name: "스타벅스",
            visitorCount: "45",
            address: "서울특별시 마포구 어울마당로",
            images: ["testImage1", "testImage2", "testImage3"],
            title: "클레오가트라",
            subTitle: "성동구 수제",
            description: "포켓몬 중 하나의 이름을 가졌지만 카페에요"
        ),
        CardPlace(
            name: "스타벅스",
            visitorCount: "45",
            address: "서울특별시 마포구 어울마당로",
            images: ["testImage1", "testImage2", "testImage3"],
            title: "클레오가트라",
            subTitle: "성동구 수제",
            description: "포켓몬 중 하나의 이름을 가졌지만 카페에요"
        )
    ])
}

//
//  PlaceDetailCard.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/15/25.
//

import SwiftUI

struct CardPlace: Identifiable {
    let id = UUID()
    let name: String
    let visitorCount: String
    let address: String
    let images: [String]
    let title: String
    let subTitle: String
    let description: String
}

// 이미지 레이아웃 컴포넌트
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

struct PlaceCard: View {
    let placeName: String
    let visitorCount: String
    let address: String
    let images: [String]
    let title: String
    let subTitle: String
    let description: String
    
    var body: some View {
        VStack(spacing: 0) {
            PlaceImagesLayout(images: images)
            
            VStack(alignment: .leading) {
                HStack(spacing: 6) {
                    
                    Text(placeName)
                        .font(.body1b)
                    
                    // TODO: 칩으로 대체
                    HStack(spacing: 4) {
                        Image(systemName: "mug.fill")
                            .font(.system(size: 12))
                        Text("카페")
                            .font(.system(size: 14.5))
                    }
                    .foregroundColor(.pink400)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.pink400.opacity(0.1))
                    .cornerRadius(16)
                    
                    Spacer()
                    HStack(spacing: 4) {
                        Image(.icAddmapGray400)
                        Text(visitorCount)
                            .font(.caption2b)
                    }
                }
            }
            .padding(15)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.body2b)
                    Text(subTitle)
                        .font(.caption1m)
                        .foregroundColor(.gray600)
                    
                }
                Text(description)
                    .font(.caption1m)
                    .foregroundColor(.spoonBlack)
            }
            .padding(15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray0)
            .cornerRadius(10)
            .padding(.horizontal, 15)
            .padding(.bottom, 15)
        }
        .background(Color.white)
        .cornerRadius(16)
    }
}

struct PlaceCardsContainer: View {
    let places: [CardPlace]
    @State private var currentPage = 0
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(Array(places.enumerated()), id: \.element.id) { index, place in
                    PlaceCard(
                        placeName: place.name,
                        visitorCount: place.visitorCount,
                        address: place.address,
                        images: place.images,
                        title: place.title,
                        subTitle: place.subTitle,
                        description: place.description
                    )
                    .padding(.horizontal, 16)
                    .tag(index)
                }
            }
            .frame(minHeight: 350)  // 최소 높이 설정
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // 페이지 인디케이터
            HStack(spacing: 8) {
                ForEach(0..<places.count, id: \.self) { index in
                    Circle()
                        .fill(currentPage == index ? Color.spoonBlack : Color.gray500)
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.gray200)
            .cornerRadius(48)
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

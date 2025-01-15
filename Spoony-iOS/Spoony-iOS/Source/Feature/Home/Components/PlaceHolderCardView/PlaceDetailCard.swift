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
                
            case 3...:
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
            // 이미지 영역
            PlaceImagesLayout(images: images)
            
            // 장소 정보
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    // 매장명
                    Text(placeName)
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                        .fontWeight(.semibold)
                    
                    // 카페 태그
                    HStack(spacing: 4) {
                        Image(systemName: "mug.fill")
                            .font(.system(size: 12))
                        Text("카페")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.pink400)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.pink400.opacity(0.1))
                    .cornerRadius(16)
                    
                    Spacer()
                    
                    // 방문객 수
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                        Text(visitorCount)
                    }
                    .foregroundColor(Color.gray)
                    .font(.system(size: 16))
                }
                
                // 주소
                Text(address)
                    .font(.system(size: 16))
                    .foregroundColor(Color.gray)
            }
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .padding(.vertical, 10)
            
            // 추가 정보 박스
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                    Text(subTitle)
                        .font(.system(size: 16))
                        .foregroundColor(.gray600)
                }
                Text(description)
                    .font(.system(size: 16))
                    .foregroundColor(.gray600)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray100)
            .cornerRadius(8)
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
            
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 2)
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
                        .fill(currentPage == index ? Color.black : Color.gray.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.top, 12)
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

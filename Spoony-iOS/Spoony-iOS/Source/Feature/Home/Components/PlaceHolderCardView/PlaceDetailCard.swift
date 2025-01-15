//
//  PlaceDetailCard.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/15/25.
//

import SwiftUI

// 데이터 모델
struct CardPlace: Identifiable {
    let id = UUID()
    let name: String
    let visitorCount: String
    let address: String
}

// 개별 카드 컴포넌트
struct PlaceCard: View {
    let placeName: String
    let visitorCount: String
    let address: String
    
    var body: some View {
        VStack(spacing: 0) {
            // 이미지 영역
            HStack(spacing: 8) {
                // 첫 번째 이미지
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .cornerRadius(8)
                
                // 두 번째 이미지
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .cornerRadius(8)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // 장소 정보
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(placeName)
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text(visitorCount)
                        .font(.system(size: 14))
                        .foregroundColor(.pink)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.pink.opacity(0.1))
                        .cornerRadius(12)
                    
                    Spacer()
                }
                
                Text(address)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 16)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 2)
    }
}

// 카드 컨테이너 컴포넌트
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
                        address: place.address
                    )
                    .padding(.horizontal, 16)
                    .tag(index)
                }
            }
            .frame(height: 200)
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
        CardPlace(name: "파오리", visitorCount: "21", address: "서울특별시 마포구 와우산로"),
        CardPlace(name: "스타벅스", visitorCount: "45", address: "서울특별시 마포구 어울마당로"),
        CardPlace(name: "블루보틀", visitorCount: "33", address: "서울특별시 마포구 성미산로")
    ])
}

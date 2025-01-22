//
//  PlaceCardsContainer.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/15/25.
//

import SwiftUI

struct PlaceCardsContainer: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    let places: [CardPlace]
    @Binding var currentPage: Int
    
    var body: some View {
        ZStack(alignment: .top) {
            Triangle()
                .fill(.white)
                .frame(width: 16.adjusted, height: 14.adjustedH)
                .offset(y: -12.adjustedH)
                .zIndex(1)
            
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
                    .onTapGesture {
                        navigationManager.push(.detailView)
                    }
                }
            }
            .frame(height: 280.adjusted)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX - 8, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX + 8, y: rect.maxY))
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    PlaceCardsContainer(
        places: [
            CardPlace(
                name: "두꺼비 커피",
                visitorCount: "124",
                address: "서울시 성동구",
                images: ["sample_cafe1", "sample_cafe2", "sample_cafe3"],
                title: "커피가 맛있는",
                subTitle: "카페",
                description: "분위기 좋고 커피가 맛있는 카페입니다."
            ),
            CardPlace(
                name: "스타벅스",
                visitorCount: "532",
                address: "서울시 강남구",
                images: ["sample_cafe2", "sample_cafe3", "sample_cafe1"],
                title: "작업하기 좋은",
                subTitle: "프랜차이즈",
                description: "와이파이가 빵빵하고 콘센트가 많은 카페입니다."
            )
        ],
        currentPage: .constant(0)
    )
    .environmentObject(NavigationManager())
    .padding(.top, 50)
}

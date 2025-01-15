//
//  Home.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/2/25.
//

import SwiftUI

struct Home: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @State private var searchText = ""
    @State private var selectedPlace: Bool = true
    
    // 샘플 데이터 업데이트 - subTitle과 description 추가
    let samplePlaces = [
        CardPlace(
            name: "파오리",
            visitorCount: "21",
            address: "서울특별시 마포구 와우산로",
            images: ["testImage1"],
            title: "클레오가트라",
            subTitle: "성동구 수제",
            description: "포켓몬 중 하나의 이름을 가졌지만 카페에요"
        ),
        CardPlace(
            name: "스타벅스",
            visitorCount: "45",
            address: "서울특별시 마포구 어울마당로",
            images: ["testImage1", "testImage2"],
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
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            // 지도 뷰
            NMapView()
                .edgesIgnoringSafeArea(.all)
            
            // 상단 검색바와 PlaceCards
            VStack {
                CustomNavigationBar(
                    style: .search(showBackButton: false),
                    searchText: $searchText,
                    onBackTapped: {},
                    onSearchSubmit: nil,
                    onLikeTapped: nil
                )
                .padding(.top, 44)
                
                if selectedPlace {
                    PlaceCardsContainer(places: samplePlaces)
                        .padding(.top, 8)
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    Home()
        .environmentObject(NavigationManager())
}

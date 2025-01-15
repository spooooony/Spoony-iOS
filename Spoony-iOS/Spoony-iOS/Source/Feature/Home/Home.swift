//
//  Home.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/2/25.
//

import SwiftUI

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
    
    // 샘플 데이터 업데이트 - 이미지 배열 추가
    let samplePlaces = [
        CardPlace(
            name: "파오리",
            visitorCount: "21",
            address: "서울특별시 마포구 와우산로",
            images: ["testImage1"]
        ),
        CardPlace(
            name: "스타벅스",
            visitorCount: "45",
            address: "서울특별시 마포구 어울마당로",
            images: ["testImage1", "testImage2"]
        ),
        CardPlace(
            name: "블루보틀",
            visitorCount: "33",
            address: "서울특별시 마포구 성미산로",
            images: ["testImage1", "testImage2", "testImage3"]
        ),
        CardPlace(
            name: "메가커피",
            visitorCount: "28",
            address: "서울특별시 마포구 성미산로",
            images: ["testImage1", "testImage2", "testImage3"]
        ),
        CardPlace(
            name: "이디야",
            visitorCount: "40",
            address: "서울특별시 마포구 성미산로",
            images: ["testImage1", "testImage2"]
        ),
        CardPlace(
            name: "투썸플레이스",
            visitorCount: "37",
            address: "서울특별시 마포구 성미산로",
            images: ["testImage1"]
        ),
        CardPlace(
            name: "폴바셋",
            visitorCount: "25",
            address: "서울특별시 마포구 성미산로",
            images: ["testImage1", "testImage2", "testImage3"]
        ),
        CardPlace(
            name: "카페베네",
            visitorCount: "31",
            address: "서울특별시 마포구 성미산로",
            images: ["testImage1", "testImage2"]
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

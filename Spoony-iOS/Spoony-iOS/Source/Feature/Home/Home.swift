//
//  Home.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/2/25.
//

import SwiftUI

struct Home: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var isBottomSheetPresented = true
    @State private var selectedPlace: Bool = true
    @State private var currentPage = 0
    @State private var searchText = ""
    @State private var searchResults: [CardPlace] = []
    
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
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
                
            NMapView()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                if case let .locationView(title) = navigationManager.mapPath.last {
                    CustomNavigationBar(
                        style: .locationTitle,
                        title: title,
                        searchText: $searchText,
                        onBackTapped: {
                            navigationManager.pop(1)
                        }
                    )
                } else {
                    CustomNavigationBar(
                        style: .searchContent,
                        searchText: $searchText,
                        onBackTapped: {
                            navigationManager.pop(1)
                        },
                        tappedAction: {
                            navigationManager.push(.searchView)
                        }
                    )
                }
                
                Spacer()
            }
            
            if isBottomSheetPresented {
                if searchResults.isEmpty {
                    FixedBottomSheetView()
                } else {
                    BottomSheetListView()
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            isBottomSheetPresented = true
        }
        .onChange(of: searchText) { _, newValue in
            // 검색어에 따라 결과 필터링
            searchResults = samplePlaces.filter { place in
                newValue.isEmpty || place.name.localizedCaseInsensitiveContains(newValue)
            }
        }
    }
}

#Preview {
    Home()
        .environmentObject(NavigationManager())
}

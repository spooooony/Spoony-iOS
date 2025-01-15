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
    
    var body: some View {
        ZStack(alignment: .top) {
            // 지도 뷰
            NMapView()
                .edgesIgnoringSafeArea(.all)
            
            // 상단 검색바
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
                    PlaceCard(
                        placeName: "파오리",
                        visitorCount: "21",
                        address: "서울특별시 마포구 와우산로 수익형"
                    )
                    .padding(.horizontal, 16)
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

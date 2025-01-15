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
    
    var body: some View {
        ZStack(alignment: .bottom) {
            NMapView()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                CustomNavigationBar(
                    style: .search(showBackButton: false),
                    searchText: $searchText,
                    onBackTapped: {},
                    onSearchSubmit: {
                        navigationManager.push(.searchView)
                    },
                    onLikeTapped: nil
                )
                
                Spacer()
            }
            
            BottomSheetListView()
                .ignoresSafeArea(.keyboard)
        }
    }
}

#Preview {
    Home()
        .environmentObject(NavigationManager())
}

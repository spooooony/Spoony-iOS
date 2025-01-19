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
    @State private var searchText = ""
    
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            NMapView()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                if let locationTitle = navigationManager.currentLocation {
                    CustomNavigationBar(
                        style: .locationTitle,
                        title: locationTitle,
                        searchText: $searchText,
                        onBackTapped: {
                            navigationManager.currentLocation = nil
                        }
                    )
                    .frame(height: 56.adjusted)
                } else {
                    CustomNavigationBar(
                        style: .searchContent,
                        searchText: $searchText,
                        tappedAction: {
                            navigationManager.push(.searchView)
                        }
                    )
                    .frame(height: 56.adjusted)
                }
                
                Spacer()
            }
            
            if isBottomSheetPresented {
                if navigationManager.currentLocation != nil {
                    BottomSheetListView()
                } else {
                    FixedBottomSheetView()
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            isBottomSheetPresented = true
        }
    }
}

#Preview {
    Home()
        .environmentObject(NavigationManager())
}

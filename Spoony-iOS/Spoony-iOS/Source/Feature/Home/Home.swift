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
    @State private var selectedPlace: CardPlace?
    @State private var currentPage = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            NMapView(selectedPlace: $selectedPlace)
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
            
            if let place = selectedPlace {
                VStack(spacing: 4) {
                    PlaceCardsContainer(places: [place], currentPage: $currentPage)
                    if [place].count > 1 {
                        PageIndicator(currentPage: currentPage, pageCount: 1)
                    }
                }
                .padding(.bottom, 4)
                .transition(.move(edge: .bottom))
            } else {
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

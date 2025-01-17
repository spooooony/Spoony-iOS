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
    @State private var showDefaultSheet = true
    
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
                if showDefaultSheet {
                    FixedBottomSheetView()
                } else {
                    CustomBottomSheet(
                        style: .half,
                        isPresented: $isBottomSheetPresented
                    ) {
                        Color.white
                    }
                    .transition(.move(edge: .bottom))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isBottomSheetPresented)
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

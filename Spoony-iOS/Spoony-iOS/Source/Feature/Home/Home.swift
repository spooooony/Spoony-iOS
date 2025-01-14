//
//  Home.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/2/25.
//

import SwiftUI

struct Home: View {
    
    @EnvironmentObject private var navigationManager: NavigationManager
    @State private var showSheet = false
    @State private var searchText = ""
    
    var body: some View {
        ZStack(alignment: .top) {
            NMapView()
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                CustomNavigationBar(
                    style: .search(showBackButton: false),
                    searchText: $searchText,
                    onBackTapped: {},
                    onSearchSubmit: nil,
                    onLikeTapped: nil
                )
                .padding(.top, 44)
                
                Spacer()
                
                BottomSheetButton(isPresented: $showSheet)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
}

#Preview {
    Home()
        .environmentObject(NavigationManager())
}

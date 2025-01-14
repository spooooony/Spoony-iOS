//
//  Home.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/2/25.
//

import SwiftUI

struct Home: View {
    
    @EnvironmentObject private var navigationManager: NavigationManager
    @State private var showListSheet = false
    @State private var showButtonSheet = false
    
    var body: some View {
        ZStack(alignment: .top) {
            NMapView()
                .edgesIgnoringSafeArea(.all)

        }
    }
}

#Preview {
    Home()
        .environmentObject(NavigationManager())
}

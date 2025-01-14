//
//  ContentView.swift
//  SpoonMe
//
//  Created by 이지훈 on 12/26/24.
//

import SwiftUI
import NMapsMap

struct ContentView: View {
    @StateObject private var navigationManager = NavigationManager()
    
    var body: some View {
        TabView(selection: $navigationManager.selectedTab) {
            NavigationStack(path: $navigationManager.mapPath) {
                Home()
            }
            
        }
        .environmentObject(navigationManager)
    }
}

#Preview {
    ContentView()
}

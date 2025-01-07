//
//  SpoonyTabView.swift
//  SpoonMe
//
//  Created by 최주리 on 1/7/25.
//

import SwiftUI

struct SpoonyTabView: View {
    
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        
        TabView(selection: $navigationManager.selectedTab) {
            NavigationStack(path: $navigationManager.mapPath) {
                Home()
                    .navigationDestination(for: ViewType.self) { view in
                        navigationManager.build(view)
                    }
            }
            .tabItem { Label("내 지도", systemImage: "safari") }
            .tag(TabType.map)
            
            NavigationStack(path: $navigationManager.explorePath) {
                Detail()
                    .navigationDestination(for: ViewType.self) { view in
                        navigationManager.build(view)
                    }
            }
            .tabItem { Label("탐색", systemImage: "magnifyingglass") }
            .tag(TabType.explore)
            
            NavigationStack(path: $navigationManager.registerPath) {
                Register()
                    .navigationDestination(for: ViewType.self) { view in
                        navigationManager.build(view)
                    }
            }
            .tabItem { Label("등록", systemImage: "plus.circle") }
            .tag(TabType.register)
        }
        
    }
}

#Preview {
    SpoonyTabView()
        .environmentObject(NavigationManager())
}

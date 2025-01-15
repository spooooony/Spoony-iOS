//
//  NavigationManager.swift
//  SpoonMe
//
//  Created by 최주리 on 1/7/25.
//

import SwiftUI

final class NavigationManager: ObservableObject {
    
    @Published var selectedTab: TabType = .map
    @Published var isTabBarVisible: Bool = true
    
    @Published var mapPath: [ViewType] = []
    @Published var explorePath: [ViewType] = []
    @Published var registerPath: [ViewType] = []
    
    @ViewBuilder
    func build(_ view: ViewType) -> some View {
        switch view {
        case .test:
            Explore()
            
        case .searchView:
            SearchView()
        case .locationView:
            Home()
            
        case .detailView:
            Home()
            
        }
    }
    
    func push(_ view: ViewType) {
        switch selectedTab {
        case .map:
            if view == .searchView {
                isTabBarVisible = false
            }
            mapPath.append(view)
        case .explore:
            explorePath.append(view)
        case .register:
            registerPath.append(view)
        }
    }

    func pop(_ depth: Int) {
        switch selectedTab {
        case .map:
            mapPath.removeLast(depth)
            if mapPath.isEmpty || !mapPath.contains(.searchView) {
                isTabBarVisible = true
            }
        case .explore:
            explorePath.removeLast(depth)
        case .register:
            registerPath.removeLast(depth)
        }
    }
    
    func popToRoot() {
        switch selectedTab {
        case .map:
            mapPath = []
        case .explore:
            explorePath = []
        case .register:
            registerPath = []
        }
    }
    
}

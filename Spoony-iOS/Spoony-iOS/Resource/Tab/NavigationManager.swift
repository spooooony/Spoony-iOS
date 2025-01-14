//
//  NavigationManager.swift
//  SpoonMe
//
//  Created by 최주리 on 1/7/25.
//

import SwiftUI

final class NavigationManager: ObservableObject {
    
    @Published var selectedTab: TabType = .map
    
    @Published var mapPath: [ViewType] = []
    @Published var explorePath: [ViewType] = []
    @Published var registerPath: [ViewType] = []
    
    @ViewBuilder
    func build(_ view: ViewType) -> some View {
        switch view {
        case .test:
            Quest()
       
        case .searchView:
            Home()
        case .locationView:
            Home()

        case .detailView:
            Home()

        }
    }
    
    func push(_ view: ViewType) {
        switch selectedTab {
        case .map:
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

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
    @Published var currentLocation: String?
    
    @Published var popup: PopupType?
    
    @MainActor @ViewBuilder
    func build(_ view: ViewType) -> some View {
        switch view {
        case .searchView:
            SearchView()
        case .locationView:
            Home()
        case .detailView(let postId):
            DetailView(postId: postId)
        case .explore:
            Explore()
        case .report(let postId):
            Report(postId: postId)
        case .searchLocationView(locationId: let locationId, locationTitle: let locationTitle):
            SearchLocation(locationId: locationId, locationTitle: locationTitle)
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
                if mapPath.isEmpty { return }
                if mapPath.contains(where: {
                    if case .locationView = $0 { return true }
                    return false
                }) {
                    currentLocation = nil
                }
                mapPath.removeLast(min(depth, mapPath.count))
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
    
    func navigateToSearchLocation(locationId: Int, locationTitle: String) {
        if let lastView = mapPath.last,
           case .searchView = lastView {
            pop(1)
        }
        
        push(.searchLocationView(
            locationId: locationId,
            locationTitle: locationTitle
        ))
    }
    
}

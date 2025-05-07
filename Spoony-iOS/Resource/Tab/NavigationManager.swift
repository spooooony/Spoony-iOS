//
//  NavigationManager.swift
//  SpoonMe
//
//  Created by 최주리 on 1/7/25.
//

import SwiftUI
import ComposableArchitecture

final class NavigationManager: ObservableObject {
    @Published var selectedTab: TabType = .map
    @Published var mapPath: [ViewType] = []
    @Published var explorePath: [ViewType] = []
    @Published var registerPath: [ViewType] = []
    @Published var currentLocation: String?
    
    @Published var popup: PopupType?
    
    @ViewBuilder
    func build(_ view: ViewType) -> some View {
        switch view {
//        case .searchView:
//            SearchView()
        case .locationView:
            Home(store: Store(initialState: .initialState, reducer: {
                MapFeature()
            }))
        case .detailView(let postId):
            PostView(postId: postId, store: Store(initialState: PostFeature.State(), reducer: {
                PostFeature()
            }))
        case .report(let postId):
            Report(postId: postId)
        case .searchLocationView(locationId: let locationId, locationTitle: let locationTitle):
            Home(store: Store(initialState: MapFeature.State.initialState) {
                   MapFeature()
               })
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
        default: return
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
        default: return
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
        default: return
        }
    }
    
//    func navigateToSearchLocation(locationId: Int, locationTitle: String) {
//        if let lastView = mapPath.last,
//           case .searchView = lastView {
//            pop(1)
//        }
//
//        push(.searchLocationView(
//            locationId: locationId,
//            locationTitle: locationTitle
//        ))
//    }
}

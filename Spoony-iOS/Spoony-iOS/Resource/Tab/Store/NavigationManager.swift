//
//  NavigationManager.swift
//  SpoonMe
//
//  Created by 최주리 on 1/7/25.
//

import SwiftUI

final class NavigationManager: ObservableObject {
    @Published private(set) var state = NavigationState()
    
    func dispatch(_ intent: NavigationIntent) {
        switch intent {
        case .changeTab(let tab):
            state.selectedTab = tab
        case .push(let nextView):
            push(nextView)
        case .pop(let depth):
            pop(depth)
        case .popToRoot:
            popToRoot()
        case .showPopup(let popup):
            state.popup = popup
        case .changePath(let path, let tab):
            switch tab {
            case .map:
                state.mapPath = path
            case .explore:
                state.explorePath = path
            case .register:
                state.registerPath = path
            }
        case .changeCurrentLocation(let location):
            state.currentLocation = location
        }
    }
    
    //TODO: 여기 어떻게 할지 생각해보기.........
    @ViewBuilder
    func build(_ view: ViewType) -> some View {
        switch view {
        case .searchView:
            SearchView()
        case .locationView:
            Home()
        case .detailView(let postId):
            DetailView(postId: postId)
        case .report(let postId):
            Report(postId: postId)
        }
    }
}

extension NavigationManager {
    private func push(_ view: ViewType) {
        switch state.selectedTab {
        case .map:
            state.mapPath.append(view)
        case .explore:
            state.explorePath.append(view)
        case .register:
            state.registerPath.append(view)
        }
    }

    private func pop(_ depth: Int) {
        switch state.selectedTab {
        case .map:
            if state.mapPath.isEmpty || state.mapPath.contains(where: {
                if case .locationView = $0 { return true }
                return false
            }) {
                state.currentLocation = nil
            }
            state.mapPath.removeLast(depth)
            
        case .explore:
            state.explorePath.removeLast(depth)
        case .register:
            state.registerPath.removeLast(depth)
        }
    }
    
    private func popToRoot() {
        switch state.selectedTab {
        case .map:
            state.mapPath = []
        case .explore:
            state.explorePath = []
        case .register:
            state.registerPath = []
        }
    }
}

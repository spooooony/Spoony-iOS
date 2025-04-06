//
//  MapCoordinator.swift
//  Spoony-iOS
//
//  Created by 최안용 on 4/6/25.
//

import Foundation

import ComposableArchitecture
import TCACoordinators

@Reducer(state: .equatable)
enum MapScreen {
    case map(MapFeature)
    case search(SearchFeature)
}

@Reducer
struct MapCoordinator {
    @ObservableState
    struct State: Equatable {
        static let initialState = State(routes: [.root(.map(.initialState), embedInNavigationView: true)])
        
        var routes: [Route<MapScreen.State>]
    }
    
    enum Action {
        case router(IndexedRouterActionOf<MapScreen>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .router(.routeAction(id: _, action: .map(.routToSearchScreen))):
                state.routes.push(.search(.initialState))
                return .none
            case .router(.routeAction(id: _, action: .search(.routeToPreviousScreen))):
                state.routes.goBack()
                return .none
            default:
                return .none
            }
        }
        .forEachRoute(\.routes, action: \.router)
    }
}

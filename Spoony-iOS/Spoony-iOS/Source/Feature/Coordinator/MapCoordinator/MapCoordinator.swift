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
    case detail(PostFeature)
}

@Reducer
struct MapCoordinator {
    @ObservableState
    struct State: Equatable {
        static let initialState = State(routes: [.root(.map(.initialState), embedInNavigationView: true)])
        
        var routes: [Route<MapScreen.State>]
        var selectedLocationId: Int?
    }
    
    enum Action {
        case router(IndexedRouterActionOf<MapScreen>)
        case locationSelected(Int)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .router(.routeAction(id: _, action: .map(.routToDetailView(postId: postId)))):
                state.routes.push(.detail(PostFeature.State(postId: postId)))
                return .none
                
            case .router(.routeAction(id: _, action: .map(.routToSearchScreen))):
                state.routes.push(.search(.initialState))
                return .none
                
            case let .locationSelected(locationId):
                state.selectedLocationId = locationId
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

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
    case searchLocation(SearchLocationFeature)
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
        
        case routeToPostScreen(Int)
        case routeToExploreTab
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .router(.routeAction(id: _, action: .map(.routeToPostView(postId: postId)))):
                return .send(.routeToPostScreen(postId))
                
            case .router(.routeAction(id: _, action: .map(.routToSearchScreen))):
                state.routes.push(.search(.initialState))
                return .none
                
            case .router(.routeAction(id: _, action: .map(.routeToExploreTab))):
                return .send(.routeToExploreTab)
                
            case .router(.routeAction(id: _, action: .searchLocation(.routeToExploreTab))):
                return .send(.routeToExploreTab)
                
            case let .router(.routeAction(id: _, action: .searchLocation(.routeToPostDetail(postId: postId)))):
                return .send(.routeToPostScreen(postId))
                
            case let .locationSelected(locationId):
                state.selectedLocationId = locationId
                return .none
                
            case .router(.routeAction(id: _, action: .search(.selectLocation(let result)))):
                let locationState = SearchLocationFeature.State(
                    locationId: result.locationId,
                    locationTitle: result.title,
                    searchedLatitude: result.latitude,
                    searchedLongitude: result.longitude
                )
                
                state.routes.push(.searchLocation(locationState))
                return .none
                
            case .router(.routeAction(id: _, action: .searchLocation(.routeToHomeScreen))):
                state.routes = [.root(.map(.initialState), embedInNavigationView: true)]
                return .none
                
            case .router(.routeAction(id: _, action: .search(.routeToPreviousScreen))):
                state.routes.goBack()
                return .none
                
            case .routeToExploreTab:
                return .none
                
            default:
                return .none
            }
        }
        .forEachRoute(\.routes, action: \.router)
    }
}

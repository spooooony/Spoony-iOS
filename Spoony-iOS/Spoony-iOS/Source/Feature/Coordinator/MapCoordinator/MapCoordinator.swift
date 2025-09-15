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
    }
    
    enum Action {
        case router(IndexedRouterActionOf<MapScreen>)
        
        // MARK: - Route Action: 화면 전환 이벤트를 상위 Reducer에 전달 시 사용
        case delegate(Delegate)
        enum Delegate {
            case routeToPostScreen(Int)
            case changeSelectedTab(TabType)
            
        }        
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .router(.routeAction(id: _, action: childDelegateAction)):
                switch childDelegateAction {
                // MARK: - Map Screen
                case .map(.delegate(let routeAction)):
                    switch routeAction {
                    case .changeSelectedTab(let tab):
                        return .send(.delegate(.changeSelectedTab(tab)))
                        
                    case .routeToPostView(let postId):
                        return .send(.delegate(.routeToPostScreen(postId)))
                        
                    case .routeToSearchScreen:
                        state.routes.push(.search(.initialState))
                        return .none
                    }
                    
                // MARK: - Search Screen
                case .search(.delegate(let routeAction)):
                    switch routeAction {
                    case .routeToPreviousScreen:
                        state.routes.goBack()
                        return .none
                        
                    case .routeToSearchLocation(let result):
                        let locationState = SearchLocationFeature.State(
                            locationId: result.locationId,
                            locationTitle: result.title,
                            searchedLatitude: result.latitude,
                            searchedLongitude: result.longitude
                        )
                        
                        state.routes.push(.searchLocation(locationState))
                        return .none
                    }
                    
                // MARK: - SearchLocation Screen
                case .searchLocation(.delegate(let routeAction)):
                    switch routeAction {
                    case .changeSelectedTab(let tab):
                        return .send(.delegate(.changeSelectedTab(tab)))
                        
                    case .routeToHomeScreen:
                        state.routes.goBackToRoot()
                        return .none
                        
                    case .routeToPostDetail(let postId):
                        return .send(.delegate(.routeToPostScreen(postId)))
                    }
                    
                default:
                    return .none
                }
                
            default:
                return .none            
            }
        }
        .forEachRoute(\.routes, action: \.router)
    }
}

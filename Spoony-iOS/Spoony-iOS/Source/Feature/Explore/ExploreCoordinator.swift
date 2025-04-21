//
//  ExploreCoordinator.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/17/25.
//

import Foundation

import ComposableArchitecture
import TCACoordinators

@Reducer
struct ExploreCoordinator {
    @ObservableState
    struct State: Equatable {
        static let initialState = State(routes: [.root(.explore(.initialState), embedInNavigationView: true)])
        
        var routes: [Route<ExploreScreen.State>]
    }
    
    enum Action {
        case router(IndexedRouterActionOf<ExploreScreen>)
        case tabSelected(TabType)
    }
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            switch action {
            case .router(.routeAction(id: _, action: .explore(.routeToExploreSearchScreen))):
                state.routes.push(.search(.initialState))
                return .none
            // 이전 화면
            case .router(.routeAction(id: _, action: .search(.routeToExploreScreen))):
                state.routes.goBack()
                return .none
            case .router(.routeAction(id: _, action: .explore(.tabSelected(let tab)))):
                return .send(.tabSelected(tab))
            default:
                return .none
            }
        }
        .forEachRoute(\.routes, action: \.router)
    }
}

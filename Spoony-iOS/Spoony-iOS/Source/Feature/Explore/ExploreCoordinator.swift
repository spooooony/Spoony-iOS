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
        case presentAlert(AlertType, Alert, AlertAction)
        case routeToPreviousScreen
    }
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            switch action {
            case .router(.routeAction(id: _, action: .explore(.routeToExploreSearchScreen))):
                state.routes.push(.search(.initialState))
                return .none
            case let .router(.routeAction(id: _, action: .explore(.routeToDetailScreen(post)))):
                state.routes.push(.detail(PostFeature.State(postId: post.postId)))
                return .none
            case let .router(.routeAction(id: _, action: .explore(.routeToReportScreen(postId)))):
                state.routes.push(.report(ReportFeature.State(postId: postId)))
                return .none
            
            // popup
            case let .router(.routeAction(id: _, action: .report(.presentAlert(type, alert, action)))):
                return .send(.presentAlert(type, alert, action))
                
            // 이전 화면
            case .router(.routeAction(id: _, action: .search(.routeToPreviousScreen))):
                state.routes.goBack()
                return .none
            case .router(.routeAction(id: _, action: .report(.routeToPreviousScreen))):
                state.routes.goBack()
                return .none
            case .router(.routeAction(id: _, action: .detail(.routeToPreviousScreen))):
                state.routes.goBack()
                return .none
            // 탭
            case .router(.routeAction(id: _, action: .explore(.tabSelected(let tab)))):
                return .send(.tabSelected(tab))
                
            case .routeToPreviousScreen:
                return .none
            default:
                return .none
            }
        }
        .forEachRoute(\.routes, action: \.router)
    }
}

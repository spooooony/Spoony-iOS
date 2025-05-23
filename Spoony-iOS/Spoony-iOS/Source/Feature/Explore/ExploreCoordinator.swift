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
            case let .router(.routeAction(id: _, action: .explore(.routeToDetailScreen(post)))):
                state.routes.push(.detail(PostFeature.State(postId: post.postId)))
                return .none
            case let .router(.routeAction(id: _, action: .explore(.routeToReportScreen(postId)))):
                state.routes.push(.report(ReportFeature.State(postId: postId)))
                return .none
            case .router(.routeAction(id: _, action: .explore(.routeToEditReviewScreen(let postId)))):
                state.routes.presentCover(.edit(.init(postId: postId)))
                return .none
                
            // 검색에서 네비게이션
            case .router(.routeAction(id: _, action: .search(.routeToDetailScreen(let post)))):
                state.routes.push(.detail(PostFeature.State(postId: post.postId)))
                return .none
            case let .router(.routeAction(id: _, action: .search(.routeToReportScreen(postId)))):
                state.routes.push(.report(ReportFeature.State(postId: postId)))
                return .none
            case .router(.routeAction(id: _, action: .search(.routeToEditReviewScreen(let postId)))):
                state.routes.presentCover(.edit(.init(postId: postId)))
                return .none
            case .router(.routeAction(id: _, action: .search(.routeToUserProfileScreen(let userId)))):
                state.routes.push(.otherProfile(.init(userId: userId)))
                return .none
            case .router(.routeAction(id: _, action: .otherProfile(.routeToReportScreen(let userId)))):
                state.routes.push(.report(ReportFeature.State(targetUserId: userId)))
                return .none
                
            // 이전 화면
            case .router(.routeAction(id: _, action: .search(.routeToExploreScreen))):
                state.routes.goBack()
                return .none
            case .router(.routeAction(id: _, action: .report(.routeToExploreScreen))):
                state.routes.goBack()
                return .none
            case .router(.routeAction(id: _, action: .detail(.routeToPreviousScreen))):
                state.routes.goBack()
                return .none
            case .router(.routeAction(id: _, action: .otherProfile(.routeToPreviousScreen))):
                state.routes.goBack()
                return .none
            case .router(.routeAction(id: _, action: .edit(.routeToPreviousScreen))):
                state.routes.dismiss()
                return .none
                
            // 탭
            case .router(.routeAction(id: _, action: .explore(.tabSelected(let tab)))):
                return .send(.tabSelected(tab))
            default:
                return .none
            }
        }
        .forEachRoute(\.routes, action: \.router)
    }
}

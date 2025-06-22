//
//  ExploreCoordinator.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/17/25.
//

import Foundation

import ComposableArchitecture
import TCACoordinators

@Reducer(state: .equatable)
enum ExploreScreen {
    case explore(ExploreFeature)
    case search(ExploreSearchFeature)
    case otherProfile(OtherProfileFeature)
    case follow(FollowFeature)
    case myProfile(ProfileFeature)
}

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
        case routeToPreviousScreen
        
        case routeToPostScreen(Int)
        case routeToPostReportScreen(Int)
        case routeToUserReportScreen(Int)
        case routeToEditReviewScreen(Int)
        case routeToReviewDetail(Int)
        case routeToFollowScreen(tab: Int)
        
        case presentToast(message: String)
    }
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            switch action {
            case .router(.routeAction(id: _, action: .explore(.routeToExploreSearchScreen))):
                state.routes.push(.search(.initialState))
                return .none
            case .router(.routeAction(id: _, action: .explore(.routeToPostScreen(let post)))):
                return .send(.routeToPostScreen(post.postId))
            case .router(.routeAction(id: _, action: .explore(.routeToReportScreen(let postId)))):
                return .send(.routeToPostReportScreen(postId))
            case .router(.routeAction(id: _, action: .explore(.routeToEditReviewScreen(let postId)))):
                return .send(.routeToEditReviewScreen(postId))
                
            // 검색에서 네비게이션
            case .router(.routeAction(id: _, action: .search(.routeToPostScreen(let post)))):
                return .send(.routeToPostScreen(post.postId))
            case let .router(.routeAction(id: _, action: .search(.routeToPostReportScreen(postId)))):
                return .send(.routeToPostReportScreen(postId))
            case .router(.routeAction(id: _, action: .search(.routeToEditReviewScreen(let postId)))):
                return .send(.routeToEditReviewScreen(postId))
            case .router(.routeAction(id: _, action: .search(.routeToUserProfileScreen(let userId)))):
                state.routes.push(.otherProfile(.init(userId: userId)))
                return .none
            case .router(.routeAction(id: _, action: .search(.routeToMyProfileScreen))):
                state.routes.push(.myProfile(.init()))
                return .none
                
            // otherProfile
            case .router(.routeAction(id: _, action: .otherProfile(.routeToReviewDetail(let postId)))):
                return .send(.routeToPostScreen(postId))
            case .router(.routeAction(id: _, action: .otherProfile(.routeToUserReportScreen(let userId)))):
                return .send(.routeToUserReportScreen(userId))
            case .router(.routeAction(id: _, action: .otherProfile(.routeToPostReportScreen(let postId)))):
                return .send(.routeToPostReportScreen(postId))
            case .router(.routeAction(id: _, action: .otherProfile(.routeToFollowScreen(let tab)))):
                if case let .otherProfile(otherProfileStore) = state.routes.last?.screen {
                    let followState = FollowFeature.State(initialTab: tab, targetUserId: otherProfileStore.userId)
                    state.routes.push(.follow(followState))
                }
                return .none
                
            // myProfile
            case .router(.routeAction(id: _, action: .myProfile(.routeToReviewDetail(let postId)))):
                return .send(.routeToPostScreen(postId))
            case .router(.routeAction(id: _, action: .myProfile(.routeToFollowScreen(let tab)))):
                let followState = FollowFeature.State(initialTab: tab)
                state.routes.push(.follow(followState))
                return .none
                
            case .router(.routeAction(id: _, action: .follow(.routeToUserProfileScreen(let userId)))):
                state.routes.push(.otherProfile(.init(userId: userId)))
                return .none
            case .router(.routeAction(id: _, action: .follow(.routeToMyProfileScreen))):
                state.routes.push(.myProfile(.init()))
                return .none
                
            // 이전 화면
            case .router(.routeAction(id: _, action: .search(.routeToPreviousScreen))):
                state.routes.goBack()
                return .none
            case .router(.routeAction(id: _, action: .otherProfile(.routeToPreviousScreen))):
                state.routes.goBack()
                return .none
            case .router(.routeAction(id: _, action: .follow(.routeToPreviousScreen))):
                state.routes.goBack()
                return .none
                
            // 탭
            case .router(.routeAction(id: _, action: .explore(.tabSelected(let tab)))):
                return .send(.tabSelected(tab))
                
            case .routeToPreviousScreen:
                return .none
            
            // toast
            case .router(.routeAction(id: _, action: .explore(.presentToast(let message)))):
                return .send(.presentToast(message: message))
            case .router(.routeAction(id: _, action: .search(.presentToast(let message)))):
                return .send(.presentToast(message: message))
            case .presentToast:
                return .none
            
            default:
                return .none
            }
        }
        .forEachRoute(\.routes, action: \.router)
    }
}

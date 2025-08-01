//
//  MyPageCoordinator.swift
//  Spoony-iOS
//
//  Created by 최안용 on 4/4/25.
//

import Foundation
import ComposableArchitecture
import TCACoordinators

@Reducer(state: .equatable)
enum MyPageScreen {
    case profile(ProfileFeature)
    case otherProfile(OtherProfileFeature)
    case reviews(RegisterFeature)
    case follow(FollowFeature)
}

@Reducer
struct MyPageCoordinator {
    @ObservableState
    struct State: Equatable {
        static let initialState = State(routes: [.root(.profile(.initialState), embedInNavigationView: true)])
        
        var routes: [Route<MyPageScreen.State>]
    }
    
    enum Action {
        case router(IndexedRouterActionOf<MyPageScreen>)
        
        case routeToRegister
        case routeToEditReviewScreen(Int)
        case routeToPostScreen(Int)
        case routeToLoginScreen
        case routeToSettingsScreen
        case routeToEditProfileScreen
        case routeToAttendanceScreen
        case routeToReportScreen(Int)
        case routeToReviewDetail(Int)
        case routeToFollowScreen(tab: Int)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .router(.routeAction(id: _, action: .profile(.routeToRegister))):
                return .send(.routeToRegister)
                
            case .routeToRegister:
                return .none
                
            case .routeToLoginScreen:
                return .none
                
            case .router(.routeAction(id: _, action: .profile(.routeToEditReviewScreen(let postId)))):
                return .send(.routeToEditReviewScreen(postId))
                
            case .router(.routeAction(id: _, action: .profile(.routeToReviewDetail(let postId)))):
                return .send(.routeToPostScreen(postId))
                
            case .router(.routeAction(id: _, action: .otherProfile(.routeToReviewDetail(let postId)))):
                return .send(.routeToPostScreen(postId))
                
            case .router(.routeAction(id: _, action: .otherProfile(.routeToUserReportScreen(let userId)))):
                return .send(.routeToReportScreen(userId))
                
            case .router(.routeAction(id: _, action: .profile(.routeToFollowScreen(let tab)))):
                let followState = FollowFeature.State(initialTab: tab)
                state.routes.push(.follow(followState))
                return .none
                
            case .router(.routeAction(id: _, action: .otherProfile(.routeToFollowScreen(let tab)))):
                if case let .otherProfile(otherProfileStore) = state.routes.last?.screen {
                    let followState = FollowFeature.State(initialTab: tab, targetUserId: otherProfileStore.userId)
                    state.routes.push(.follow(followState))
                }
                return .none
                
            case .router(.routeAction(id: _, action: .follow(.routeToUserProfileScreen(let userId)))):
                state.routes.push(.otherProfile(.init(userId: userId)))
                return .none
            case .router(.routeAction(id: _, action: .follow(.routeToMyProfileScreen))):
                state.routes.push(.profile(.init(isRootView: false)))
                return .none
                
            case .router(.routeAction(id: _, action: .profile(.routeToSettingsScreen))):
                return .send(.routeToSettingsScreen)
                
            case .router(.routeAction(id: _, action: .profile(.routeToAttendanceScreen))):
                return .send(.routeToAttendanceScreen)
                
            case .router(.routeAction(id: _, action: .profile(.routeToEditProfileScreen))):
                return .send(.routeToEditProfileScreen)
                
            case .router(.routeAction(id: _, action: .reviews(.routeToPreviousScreen))),
                 .router(.routeAction(id: _, action: .follow(.routeToPreviousScreen))),
                 .router(.routeAction(id: _, action: .otherProfile(.routeToPreviousScreen))),
                 .router(.routeAction(id: _, action: .profile(.routeToPreviousScreen))):
                state.routes.goBack()
                return .none
                
            case .routeToPostScreen, .routeToEditReviewScreen, .routeToSettingsScreen, .routeToEditProfileScreen, .routeToAttendanceScreen:
                return .none
                
            default:
                return .none
            }
        }
        .forEachRoute(\.routes, action: \.router)
    }
}

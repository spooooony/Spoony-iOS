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
        
        // MARK: - Route Action: 화면 전환 이벤트를 상위 Reducer에 전달 시 사용
        case delegate(Delegate)
        enum Delegate {
            case changeSelectedTab(TabType)
            case routeToPostScreen(Int)
            case routeToPostReportScreen(Int)
            case routeToUserReportScreen(Int)
            case routeToEditReviewScreen(Int)
            case routeToReviewDetail(Int)
            case routeToFollowScreen(tab: Int)
            case routeToRegisterScreen
            case routeToSettingsScreen
            case routeToAttendanceScreen
            case routeToEditProfileScreen
            case presentToast(ToastType)
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            // MARK: - RouterAction
            case let .router(.routeAction(id: _, action: childDelegateAction)):
                // MARK: - 자식 Delegate Action
                switch childDelegateAction {
                // MARK: - Explore Screen RouteAction
                case .explore(.delegate(let routeAction)):
                    switch routeAction {
                    case .routeToExploreSearchScreen:
                        state.routes.push(.search(.initialState))
                        return .none
                        
                    case .routeToReportScreen(let postId):
                        return .send(.delegate(.routeToPostReportScreen(postId)))
                        
                    case .routeToEditReviewScreen(let postId):
                        return .send(.delegate(.routeToEditReviewScreen(postId)))
                        
                    case .presentToast(let type):
                        return .send(.delegate(.presentToast(type)))
                        
                    case .changeSelectedTab(let tab):
                        return .send(.delegate(.changeSelectedTab(tab)))
                        
                    case .routeToPostScreen(let post):
                        return .send(.delegate(.routeToPostScreen(post.postId)))
                    }
                    
                // MARK: - Follow Screen RouteAction
                case .follow(.delegate(let routeAction)):
                    switch routeAction {
                    case .routeToMyProfileScreen:
                        state.routes.push(.myProfile(.init(isRootView: false)))
                        return .none
                                            
                    case .routeToUserProfileScreen(let userId):
                        state.routes.push(.otherProfile(.init(userId: userId)))
                        return .none
                        
                    case .routeToPreviousScreen:
                        state.routes.goBack()
                        return .none
                    }
                    
                // MARK: - MyProfile Screen RouteAction
                case .myProfile(.delegate(let routeAction)):
                    switch routeAction {
                    case .routeToReviewDetail(let postId):
                        return .send(.delegate(.routeToPostScreen(postId)))
                        
                    case .routeToFollowScreen(let tab):
                        let followState = FollowFeature.State(initialTab: tab)
                        state.routes.push(.follow(followState))
                        return .none
                     
                    case .routeToRegister:
                        return .send(.delegate(.routeToRegisterScreen))
                        
                    case .routeToSettingsScreen:
                        return .send(.delegate(.routeToSettingsScreen))
                        
                    case .routeToAttendanceScreen:
                        return .send(.delegate(.routeToAttendanceScreen))
                        
                    case .routeToEditProfileScreen:
                        return .send(.delegate(.routeToEditProfileScreen))
                        
                    case .routeToEditReviewScreen(let postId):
                        return .send(.delegate(.routeToEditReviewScreen(postId)))
                        
                    case .routeToPreviousScreen:
                        state.routes.goBack()
                        return .none
                    }
                    
                // MARK: - OtherProfile Screen RouteAction
                case .otherProfile(.delegate(let routeAction)):
                    switch routeAction {
                    case .routeToReviewDetail(let postId):
                        return .send(.delegate(.routeToPostScreen(postId)))
                        
                    case .routeToUserReportScreen(let userId):
                        return .send(.delegate(.routeToUserReportScreen(userId)))
                        
                    case .routeToPostReportScreen(let postId):
                        return .send(.delegate(.routeToPostReportScreen(postId)))
                        
                    case .routeToFollowScreen(let tab):
                        if case let .otherProfile(otherProfileStore) = state.routes.last?.screen {
                            let followState = FollowFeature.State(
                                initialTab: tab,
                                targetUserId: otherProfileStore.userId
                            )
                            state.routes.push(.follow(followState))
                        }
                        
                        return .none
                        
                    case .routeToPreviousScreen:
                        state.routes.goBack()
                        return .none
                        
                    case .presentToast(let type):
                        return .send(.delegate(.presentToast(type)))
                    case .routeToRoot:
                        state.routes.goBackToRoot()
                        return .none
                    }
                    
                // MARK: - Search Screen RouteAction
                case .search(.delegate(let routeAction)):
                    switch routeAction {
                    case .routeToPostScreen(let post):
                        return .send(.delegate(.routeToPostScreen(post.postId)))
                        
                    case .routeToPostReportScreen(let postId):
                        return .send(.delegate(.routeToPostReportScreen(postId)))
                        
                    case .routeToEditReviewScreen(let postId):
                        return .send(.delegate(.routeToEditReviewScreen(postId)))
                        
                    case .routeToUserProfileScreen(let userId):
                        state.routes.push(.otherProfile(.init(userId: userId)))
                        return .none
                        
                    case .routeToMyProfileScreen:
                        state.routes.push(.myProfile(.init(isRootView: false)))
                        return .none
                        
                    case .routeToPreviousScreen:
                        state.routes.goBack()
                        return .none
                        
                    case .presentToast(let type):
                        return .send(.delegate(.presentToast(type)))
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

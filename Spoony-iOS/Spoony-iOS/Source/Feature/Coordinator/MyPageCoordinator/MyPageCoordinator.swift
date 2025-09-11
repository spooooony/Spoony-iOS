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
        
        // MARK: - Route Action: 화면 전환 이벤트를 상위 Reducer에 전달 시 사용
        case delegate(Delegate)
        enum Delegate {
            case routeToRegisterScreen
            case routeToEditReviewScreen(Int)
            case routeToPostScreen(Int)
            case routeToLoginScreen
            case routeToSettingsScreen
            case routeToEditProfileScreen
            case routeToAttendanceScreen
            case routeToPostReportScreen(Int)
            case routeToUserReportScreen(Int)
            case routeToReviewDetail(Int)
            case routeToFollowScreen(tab: Int)
            case presentPopup(PopupType)
            case presentToast(ToastType)
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .router(.routeAction(id: _, action: childDelegateAction)):
                switch childDelegateAction {
                // MARK: - Follow Screen
                case .follow(.delegate(let routeAction)):
                    switch routeAction {
                    case .routeToPreviousScreen:
                        state.routes.goBack()
                        return .none
                        
                    case .routeToUserProfileScreen(let userId):
                        state.routes.push(.otherProfile(.init(userId: userId)))
                        return .none
                        
                    case .routeToMyProfileScreen:
                        state.routes.push(.profile(.init(isRootView: false)))
                        return .none
                    }
                  
                // MARK: - OtherProfile Screen
                case .otherProfile(.delegate(let routeAction)):
                    switch routeAction {
                    case .routeToReviewDetail(let postId):
                        return .send(.delegate(.routeToPostScreen(postId)))
                        
                    case .routeToPreviousScreen:
                        state.routes.goBack()
                        return .none
                        
                    case .routeToFollowScreen(let tab):
                        if case let .otherProfile(otherProfileStore) = state.routes.last?.screen {
                            let followState = FollowFeature.State(initialTab: tab, targetUserId: otherProfileStore.userId)
                            state.routes.push(.follow(followState))
                        }
                        return .none
                        
                    case .routeToPostReportScreen(let postId):
                        return .send(.delegate(.routeToPostReportScreen(postId)))
                        
                    case .routeToUserReportScreen(let userId):
                        return .send(.delegate(.routeToUserReportScreen(userId)))
                        
                    case .presentToast(let type):
                        return .send(.delegate(.presentToast(type)))
                    }
                    
                // MARK: - Profile Screen
                case .profile(.delegate(let routeAction)):
                    switch routeAction {
                    case .routeToFollowScreen(let tab):
                        let followState = FollowFeature.State(initialTab: tab)
                        state.routes.push(.follow(followState))
                        return .none
                        
                    case .routeToSettingsScreen:
                        return .send(.delegate(.routeToSettingsScreen))
                        
                    case .routeToAttendanceScreen:
                        return .send(.delegate(.routeToAttendanceScreen))
                        
                    case .routeToEditProfileScreen:
                        return .send(.delegate(.routeToEditProfileScreen))
                        
                    case .routeToEditReviewScreen(let postId):
                        return .send(.delegate(.routeToEditReviewScreen(postId)))
                        
                    case .routeToRegister:
                        return .send(.delegate(.routeToRegisterScreen))
                        
                    case .routeToPreviousScreen:
                        state.routes.goBack()
                        return .none
                        
                    case .routeToReviewDetail(let postId):
                        return .send(.delegate(.routeToPostScreen(postId)))
                    }
                    
                // MARK: - Reviews Screen
                case .reviews(.delegate(let routeAction)):
                    switch routeAction {                        
                    case .presentPopup(let type):
                        return .send(.delegate(.presentPopup(type)))
                        
                    case .presentToast(let type):
                        return .send(.delegate(.presentToast(type)))
                        
                    case .routeToPostScreen(let postId):
                        return .send(.delegate(.routeToPostScreen(postId)))
                        
                    case .routeToPreviousScreen:
                        state.routes.goBack()
                        return .none
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

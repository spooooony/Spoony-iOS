//
//  TabRootCoordinator.swift
//  Spoony-iOS
//
//  Created by 최안용 on 5/27/25.
//

import Foundation

import ComposableArchitecture
import TCACoordinators

@Reducer(state: .equatable)
enum TabRootScreen {
    // tab
    case tab(TabCoordinator)
    
    // 리뷰 등록 및 수정
    case registerAndEdit(RegisterFeature)
    
    // 마이페이지 설정관련
    case settings(SettingsFeature)
    case editProfile(EditProfileFeature)
    case accountManagement(AccountManagementFeature)
    case blockedUsers(BlockedUsersFeature)
    case withdraw(WithdrawFeature)
    
    //출첵
    case attendance(AttendanceFeature)
    
    case post(PostFeature)
    case report(ReportFeature)
    
    case profile(OtherProfileFeature)
    case follow(FollowFeature)
    case myProfile(ProfileFeature)
}

@Reducer
struct TabRootCoordinator {
    @ObservableState
    struct State: Equatable {
        static let initialState = State(routes: [.root(.tab(.initialState), embedInNavigationView: true)])
        
        var routes: [Route<TabRootScreen.State>]
        
        var toast: Toast?
        var popup: PopupType?
    }
    
    enum Action {
        case router(IndexedRouterActionOf<TabRootScreen>)
        
        case popupAction(PopupType)
        
        case updateToast(Toast?)
        case updatePopup(PopupType?)
        case routeToRoot
        // MARK: - Route Action: 화면 전환 이벤트를 상위 Reducer에 전달 시 사용
        case delegate(Delegate)
        enum Delegate {
            case routeToLoginScreen
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .router(.routeAction(id: _, action: childDelegateAction)):
                switch childDelegateAction {
                case .tab(.delegate(let routeAction)):
                    switch routeAction {                    
                    case .routeToLoginScreen:
                        return .send(.delegate(.routeToLoginScreen))
                        
                    case .routeToRegisterScreen:
                        state.routes.push(.registerAndEdit(.initialState))
                        return .none
                        
                    case .routeToEditReviewScreen(let postId):
                        state.routes.push(.registerAndEdit(.init(postId: postId)))
                        return .none
                        
                    case .routeToSettingsScreen:
                        state.routes.push(.settings(.initialState))
                        return .none
                        
                    case .routeToAttendanceScreen:
                        state.routes.push(.attendance(.initialState))
                        return .none
                        
                    case .routeToEditProfileScreen:
                        state.routes.push(.editProfile(.initialState))
                        return .none
                        
                    case .routeToPostScreen(let postId):
                        state.routes.push(.post(.init(postId: postId )))
                        return .none
                        
                    case .routeToPostReportScreen(let postId):
                        state.routes.push(.report(.init(postId: postId)))
                        return .none
                        
                    case .routeToUserReportScreen(let userId):
                        state.routes.push(.report(.init(targetUserId: userId)))
                        return .none
                        
                    case .routeToFollowScreen(let tab):
                        if case let .profile(otherProfileStore) = state.routes.last?.screen {
                            let followState = FollowFeature.State(
                                initialTab: tab,
                                targetUserId: otherProfileStore.userId
                            )
                            state.routes.push(.follow(followState))
                        }
                        return .none
                        
                    case .presentToast(let type):
                        state.toast = .init(message: type.message)
                        return .none
                        
                    case .presentPopup(let type):
                        state.popup = type
                        return .none
                    }
                    
                case .registerAndEdit(.delegate(let routeAction)):
                    switch routeAction {
                    case .presentPopup(let type):
                        state.popup = type
                        return .none
                    case .presentToast(let type):
                        state.toast = .init(message: type.message)
                        return .none
                        
                    case .routeToPostScreen(let postId):
                        state.routes.push(.post(.init(postId: postId)))
                        return .none
                        
                    case .routeToPreviousScreen:
                        state.routes.goBack()
                        return .none
                    }
                    
                case .settings(.delegate(let routeAction)):
                    switch routeAction {
                    case .routeToAccountManagementScreen:
                        state.routes.push(.accountManagement(.initialState))
                        return .none
                        
                    case .routeToBlockedUsersScreen:
                        state.routes.push(.blockedUsers(.initialState))
                        return .none
                        
                    case .routeToPreviousScreen:
                        state.routes.goBack()
                        return .none
                    }
                    
                case .editProfile(.delegate(let routeAction)):
                    switch routeAction {
                    case .routeToPreviousScreen:
                        state.routes.goBack()
                        return .none
                        
                    case .presentToast(let type):
                        state.toast = .init(message: type.message)
                        return .none
                    }
                    
                case .accountManagement(.delegate(let routeAction)):
                    switch routeAction {
                    case .routeToWithdrawScreen:
                        state.routes.push(.withdraw(.initialState))
                        return .none
                        
                    case .routeToPreviousScreen:
                        state.routes.goBack()
                        return .none
                        
                    case .routeToLoginScreen:
                        return .send(.delegate(.routeToLoginScreen))
                    }
                    
                case .blockedUsers(.delegate(let routeAction)):
                    switch routeAction {
                    case .routeToPreviousScreen:
                        state.routes.goBack()
                        return .none
                    }
                    
                case .withdraw(.delegate(let routeAction)):
                    switch routeAction {
                    case .routeToLoginScreen:
                        return .send(.delegate(.routeToLoginScreen))
                        
                    case .routeToPreviousScreen:
                        state.routes.goBack()
                        return .none
                    }
                    
                case .attendance(.delegate(let routeAction)):
                    switch routeAction {
                    case .routeToPreviousScreen:
                        state.routes.goBack()
                        return .none
                    }
                    
                case .post(.delegate(let routeAction)):
                    switch routeAction {
                    case .routeToPreviousScreen:
                        state.routes.goBack()
                        return .none
                        
                    case .routeToReportScreen(let postId):
                        state.routes.push(.report(.init(postId: postId)))
                        return .none
                        
                    case .routeToEditReviewScreen(let postId):
                        state.routes.push(.registerAndEdit(.init(postId: postId)))
                        return .none
                        
                    case .routeToUserProfileScreen(let userId):
                        state.routes.push(.profile(.init(userId: userId)))
                        return .none
                        
                    case .routeToMyProfileScreen:
                        state.routes.push(.myProfile(.init(isRootView: false)))
                        return .none
                        
                    case .routeToAttendanceView:
                        state.routes.push(.attendance(.initialState))
                        return .none
                        
                    case .presentToast(let type):
                        state.toast = .init(message: type.message)
                        return .none
                    }
                    
                case .report(.delegate(let routeAction)):
                    switch routeAction {
                    case .routeToPreviousScreen:
                        state.routes.goBack()
                        return .none
                    case .routeToRoot:
                        state.routes.goBackToRoot()
                        return .none
                        
                    case .presentToast(let type):
                        state.toast = .init(message: type.message)
                        return .none
                    }
                    
                case .profile(.delegate(let routeAction)):
                    switch routeAction {
                    case .routeToReviewDetail(let postId):
                        state.routes.push(.post(.init(postId: postId)))
                        return .none
                        
                    case .routeToPreviousScreen:
                        state.routes.goBack()
                        return .none
                        
                    case .routeToFollowScreen(tab: let tab):
                        if case let .profile(otherProfileStore) = state.routes.last?.screen {
                            let followState = FollowFeature.State(initialTab: tab, targetUserId: otherProfileStore.userId)
                            state.routes.push(.follow(followState))
                        }
                        return .none
                        
                    case .routeToPostReportScreen(let postId):
                        state.routes.push(.report(.init(postId: postId)))
                        return .none
                        
                    case .routeToUserReportScreen(let userId):
                        state.routes.push(.report(.init(targetUserId: userId)))
                        return .none
                    case .presentToast(let type):
                        state.toast = .init(message: type.message)
                        return .none
                    }
                    
                case .follow(.delegate(let routeAction)):
                    switch routeAction {
                    case .routeToPreviousScreen:
                        state.routes.goBack()
                        return .none
                        
                    case .routeToUserProfileScreen(userId: let userId):
                        state.routes.push(.profile(.init(userId: userId)))
                        return .none
                        
                    case .routeToMyProfileScreen:
                        state.routes.push(.myProfile(.initialState))
                        return .none
                    }
                    
                case .myProfile(.delegate(let routeAction)):
                    switch routeAction {
                    case .routeToFollowScreen(tab: let tab):
                        let followState = FollowFeature.State(initialTab: tab)
                        state.routes.push(.follow(followState))
                        return .none
                        
                    case .routeToSettingsScreen:
                        state.routes.push(.settings(.initialState))
                        return .none
                        
                    case .routeToAttendanceScreen:
                        state.routes.push(.attendance(.initialState))
                        return .none
                        
                    case .routeToEditProfileScreen:
                        state.routes.push(.editProfile(.initialState))
                        return .none
                        
                    case .routeToEditReviewScreen(let postId):
                        state.routes.push(.registerAndEdit(.init(postId: postId)))
                        return .none
                        
                    case .routeToRegister:
                        state.routes.push(.registerAndEdit(.initialState))
                        return .none
                        
                    case .routeToPreviousScreen:
                        state.routes.goBack()
                        return .none
                        
                    case .routeToReviewDetail(let postId):
                        state.routes.push(.post(.init(postId: postId)))
                        return .none
                    }
                    
                default:
                    return .none
                }
                // popup
            case .popupAction(let type):
                switch type {
                case .useSpoon, .delete:
                    return .none
                case .reportSuccess:
                    state.routes.goBack()
                    return .none
                case .registerSuccess:
                    state.routes.goBack()
                    return .concatenate(
                        .send(.router(.routeAction(id: 0, action: .tab(.changeSelectedTab(.explore)))))
                    )
                }
                
            case .updatePopup(let popup):
                state.popup = popup
                return .none
                
            default: return .none
            }
        }
        .forEachRoute(\.routes, action: \.router)
    }
}

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
        case routeToLogin
        case routeToRoot
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .router(.routeAction(id: _, action: .tab(.routeToRegister))):
                state.routes.push(.registerAndEdit(.initialState))
                return .none
            
            case .router(.routeAction(id: _, action: .registerAndEdit(.routeToPreviousScreen))):
                state.routes.goBack()
                return .none
                
            case .router(.routeAction(id: _, action: .registerAndEdit(.routeToPostScreen(let postId)))):
                if state.routes.count >= 3 {
                    if case .post = state.routes[1].screen {
                        state.routes.goBack()
                        return .none
                    }
                }
                
                return .routeWithDelaysIfUnsupported(state.routes, action: \.router) {
                    $0.pop()
                    $0.push(.post(PostFeature.State(postId: postId)))
                }
                
            case .router(.routeAction(id: _, action: .tab(.routeToEditReview(let postId)))):
                state.routes.push(.registerAndEdit(.init(postId: postId)))
                return .none
                
            case .router(.routeAction(id: _, action: .tab(.routeToSettings))):
                state.routes.push(.settings(.initialState))
                return .none
                
            case .router(.routeAction(id: _, action: .tab(.routeToAttendance))):
                state.routes.push(.attendance(.initialState))
                return .none
                
            case .router(.routeAction(id: _, action: .tab(.routeToEditProfile))):
                state.routes.push(.editProfile(.initialState))
                return .none
                
            case .router(.routeAction(id: _, action: .tab(.routeToPost(let post)))):
                state.routes.push(.post(PostFeature.State(postId: post)))
                return .none
                
            case .router(.routeAction(id: _, action: .post(.routeToUserProfileScreen(let user)))):
                state.routes.push(.profile(OtherProfileFeature.State(userId: user)))
                return .none
                
            case .router(.routeAction(id: _, action: .post(.routeToMyProfileScreen))):
                state.routes.push(.myProfile(.initialState))
                return .none
                
            case .router(.routeAction(id: _, action: .tab(.routeToUserReport(let userId)))):
                state.routes.push(.report(ReportFeature.State(targetUserId: userId)))
                return .none
                
            case .router(.routeAction(id: _, action: .tab(.routeToPostReport(let postId)))):
                state.routes.push(.report(ReportFeature.State(postId: postId)))
                return .none
                
            case .router(.routeAction(id: _, action: .settings(.routeToAccountManagementScreen))):
                state.routes.push(.accountManagement(.initialState))
                return .none
                
            case .router(.routeAction(id: _, action: .settings(.routeToBlockedUsersScreen))):
                state.routes.push(.blockedUsers(.initialState))
                return .none
                
            case .router(.routeAction(id: _, action: .accountManagement(.routeToWithdrawScreen))):
                state.routes.push(.withdraw(.initialState))
                return .none
                
            case .router(.routeAction(id: _, action: .accountManagement(.routeToLoginScreen))):
                return .send(.routeToLogin)
                
            case .router(.routeAction(id: _, action: .withdraw(.routeToLoginScreen))):
                 return .send(.routeToLogin)
                
            case .routeToLogin:
                return .none

            case .router(.routeAction(id: _, action: .post(.routeToEditReviewScreen(let postId)))):
                state.routes.push(.registerAndEdit(.init(postId: postId)))
                return .none
                
            case .router(.routeAction(id: _, action: .post(.routeToReportScreen(let postId)))):
                state.routes.push(.report(ReportFeature.State(postId: postId)))
                return .none
            
            // profile
            case .router(.routeAction(id: _, action: .profile(.routeToUserReportScreen(let userId)))):
                state.routes.push(.report(ReportFeature.State(targetUserId: userId)))
                return .none
                
            case .router(.routeAction(id: _, action: .profile(.routeToPostReportScreen(let postId)))):
                state.routes.push(.report(ReportFeature.State(postId: postId)))
                return .none
                
            case .router(.routeAction(id: _, action: .profile(.routeToReviewDetail(let postId)))):
                state.routes.push(.post(PostFeature.State(postId: postId)))
                return .none
                
            case .router(.routeAction(id: _, action: .profile(.routeToFollowScreen(let tab)))):
                if case let .profile(otherProfileStore) = state.routes.last?.screen {
                    let followState = FollowFeature.State(initialTab: tab, targetUserId: otherProfileStore.userId)
                    state.routes.push(.follow(followState))
                }
                return .none
                
            // follow
            case .router(.routeAction(id: _, action: .follow(.routeToUserProfileScreen(let user)))):
                state.routes.push(.profile(OtherProfileFeature.State(userId: user)))
                return .none
            case .router(.routeAction(id: _, action: .follow(.routeToMyProfileScreen))):
                state.routes.push(.myProfile(.init()))
                return .none
                
            case .router(.routeAction(id: _, action: .settings(.routeToPreviousScreen))),
                    .router(.routeAction(id: _, action: .accountManagement(.routeToPreviousScreen))),
                    .router(.routeAction(id: _, action: .blockedUsers(.routeToPreviousScreen))),
                    .router(.routeAction(id: _, action: .editProfile(.routeToPreviousScreen))),
                    .router(.routeAction(id: _, action: .withdraw(.routeToPreviousScreen))),
                    .router(.routeAction(id: _, action: .attendance(.routeToPreviousScreen))),
                    .router(.routeAction(id: _, action: .post(.routeToPreviousScreen))),
                    .router(.routeAction(id: _, action: .report(.routeToPreviousScreen))),
                    .router(.routeAction(id: _, action: .profile(.routeToPreviousScreen))):
                state.routes.goBack()
                return .none
                
            //myPage
            case .router(.routeAction(id: _, action: .myProfile(.routeToReviewDetail(let postId)))):
                state.routes.push(.post(PostFeature.State(postId: postId)))
                return .none
            case .router(.routeAction(id: _, action: .myProfile(.routeToFollowScreen(let tab)))):
                let followState = FollowFeature.State(initialTab: tab)
                state.routes.push(.follow(.initialState))
                return .none
            case .router(.routeAction(id: _, action: .myProfile(.routeToRegister))):
                state.routes.push(.registerAndEdit(.initialState))
                return .none
            case .router(.routeAction(id: _, action: .myProfile(.routeToSettingsScreen))):
                state.routes.push(.settings(.initialState))
                return .none
            case .router(.routeAction(id: _, action: .myProfile(.routeToAttendanceScreen))):
                state.routes.push(.attendance(.initialState))
                return .none
            case .router(.routeAction(id: _, action: .myProfile(.routeToEditProfileScreen))):
                state.routes.push(.editProfile(.initialState))
                return .none
            case .router(.routeAction(id: _, action: .myProfile(.routeToEditReviewScreen(let postId)))):
                state.routes.push(.registerAndEdit(.init(postId: postId)))
                return .none
                
            // toast
            case .updateToast(let toast):
                state.toast = toast
                return .none
                
            case .router(.routeAction(id: _, action: .registerAndEdit(.presentToast(message: let message)))),
                    .router(.routeAction(id: _, action: .editProfile(.presentToast(message: let message)))),
                    .router(.routeAction(id: _, action: .tab(.presentToast(message: let message)))):
                state.toast = .init(style: .gray, message: message, yOffset: 665.adjustedH  )
                return .none
                
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
                                .send(.router(.routeAction(id: 0, action: .tab(.switchToExploreTab))))
                            )
                }
                
            case .updatePopup(let popup):
                state.popup = popup
                return .none
                
            case .router(.routeAction(id: _, action: .registerAndEdit(.presentPopup))):
                state.popup = .registerSuccess
                return .none
                
//            case .router(.routeAction(id: _, action: .registerAndEdit(.presentPopup)))
                
            case .router(.routeAction(id: _, action: .report(.routeToRoot))):
                return .send(.routeToRoot)
                
            case .routeToRoot:
                repeat {
                    state.routes.goBack()
                } while state.routes.count > 1
                
                return .concatenate(.send(.router(.routeAction(id: 0, action: .tab(.routeToRoot)))))
                
            default: return .none
            }
        }
        .forEachRoute(\.routes, action: \.router)
    }
}

//
//  MyPageCoordinator.swift
//  Spoony-iOS
//
//  Created by 최안용 on 4/4/25.
//

import Foundation
import ComposableArchitecture
import TCACoordinators

@Reducer
struct MyPageCoordinator {
    @ObservableState
    struct State: Equatable {
        static let initialState = State(routes: [.root(.profile(.initialState), embedInNavigationView: true)])
        
        var routes: [Route<MyPageScreen.State>]
    }
    
    enum Action {
        case router(IndexedRouterActionOf<MyPageScreen>)
        case routeToRegisterTab
        case routeToLoginScreen
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .router(.routeAction(id: _, action: .profile(.routeToRegisterTab))):
                return .send(.routeToRegisterTab)
                
            case .routeToRegisterTab:
                return .none
                
            case .router(.routeAction(id: _, action: .accountManagement(.routeToLoginScreen))):
                return .send(.routeToLoginScreen)
                
            case .router(.routeAction(id: _, action: .withdraw(.routeToLoginScreen))):
                return .send(.routeToLoginScreen)
                
            case .routeToLoginScreen:
                return .none
                
            case .router(.routeAction(id: _, action: .profile(.routeToEditReviewScreen(let postId)))):
                state.routes.presentCover(.reviews(.init(postId: postId)))
                return .none
                
            case .router(.routeAction(id: _, action: .profile(.routeToFollowingScreen))):
                state.routes.push(.follow(.initialState))
                return .none
                
            case .router(.routeAction(id: _, action: .follow(.routeToUserProfileScreen(let userId)))):
                state.routes.push(.otherProfile(.init(userId: userId)))
                return .none
                
            case .router(.routeAction(id: _, action: .profile(.routeToEditProfileScreen))):
                state.routes.push(.editProfile(.initialState))
                return .none
                
            case .router(.routeAction(id: _, action: .profile(.routeToSettingsScreen))):
                state.routes.push(.settings(.initialState))
                return .none
                
            case .router(.routeAction(id: _, action: .profile(.routeToAttendanceScreen))):
                state.routes.push(.attendance(.initialState))
                return .none
                
            case .router(.routeAction(id: _, action: .settings(.routeToAccountManagementScreen))):
                state.routes.push(.accountManagement(.initialState))
                return .none
                
            case .router(.routeAction(id: _, action: .settings(.routeToBlockedUsersScreen))):
                state.routes.push(.blockedUsers(.initialState))
                return .none
                
            case .router(.routeAction(id: _, action: .settings(.routeToTermsOfServiceScreen))):
                state.routes.push(.termsOfService(.initialState))
                return .none
                
            case .router(.routeAction(id: _, action: .settings(.routeToPrivacyPolicyScreen))):
                state.routes.push(.privacyPolicy(.initialState))
                return .none
                
            case .router(.routeAction(id: _, action: .settings(.routeToLocationServicesScreen))):
                state.routes.push(.locationServices(.initialState))
                return .none
                
            case .router(.routeAction(id: _, action: .settings(.routeToInquiryScreen))):
                state.routes.push(.inquiry(.initialState))
                return .none
                
            case .router(.routeAction(id: _, action: .accountManagement(.routeToWithdrawScreen))):
                state.routes.push(.withdraw(.initialState))
                return .none
                
            case .router(.routeAction(id: _, action: .reviews(.routeToPreviousScreen))),
                 .router(.routeAction(id: _, action: .follow(.routeToPreviousScreen))),
                 .router(.routeAction(id: _, action: .editProfile(.routeToPreviousScreen))),
                 .router(.routeAction(id: _, action: .settings(.routeToPreviousScreen))),
                 .router(.routeAction(id: _, action: .attendance(.routeToPreviousScreen))),
                 .router(.routeAction(id: _, action: .otherProfile(.routeToPreviousScreen))),
                 .router(.routeAction(id: _, action: .accountManagement(.routeToPreviousScreen))),
                 .router(.routeAction(id: _, action: .blockedUsers(.routeToPreviousScreen))),
                 .router(.routeAction(id: _, action: .termsOfService(.routeToPreviousScreen))),
                 .router(.routeAction(id: _, action: .privacyPolicy(.routeToPreviousScreen))),
                 .router(.routeAction(id: _, action: .locationServices(.routeToPreviousScreen))),
                 .router(.routeAction(id: _, action: .inquiry(.routeToPreviousScreen))),
                 .router(.routeAction(id: _, action: .withdraw(.routeToPreviousScreen))):
                state.routes.goBack()
                return .none
                
            default:
                return .none
            }
        }
        .forEachRoute(\.routes, action: \.router)
    }
}

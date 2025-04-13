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
        static let initialState = State(routes: [.root(.profile(.initialState), embedInNavigationView: false)])
        
        var routes: [Route<MyPageScreen.State>]
    }
    
    enum Action {
        case router(IndexedRouterActionOf<MyPageScreen>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .router(.routeAction(id: _, action: .profile(.routeToReviewsScreen))):
                state.routes.push(.reviews(.initialState))
                return .none
                
            case .router(.routeAction(id: _, action: .profile(.routeToFollowingScreen))):
                state.routes.push(.following(.initialState))
                return .none
                
            case .router(.routeAction(id: _, action: .profile(.routeToFollowerScreen))):
                state.routes.push(.follower(.initialState))
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
                
            // 이전 화면으로 돌아가기
            case .router(.routeAction(id: _, action: .reviews(.routeToPreviousScreen))),
                 .router(.routeAction(id: _, action: .following(.routeToPreviousScreen))),
                 .router(.routeAction(id: _, action: .follower(.routeToPreviousScreen))),
                 .router(.routeAction(id: _, action: .editProfile(.routeToPreviousScreen))),
                 .router(.routeAction(id: _, action: .settings(.routeToPreviousScreen))),
                 .router(.routeAction(id: _, action: .attendance(.routeToPreviousScreen))):
                state.routes.goBack()
                return .none
                
            default:
                return .none
            }
        }
        .forEachRoute(\.routes, action: \.router)
    }
}

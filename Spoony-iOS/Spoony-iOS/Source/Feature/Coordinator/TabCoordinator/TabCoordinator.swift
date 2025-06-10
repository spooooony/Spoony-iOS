//
//  TabCoordinator.swift
//  Spoony-iOS
//
//  Created by 최안용 on 4/1/25.
//

import Foundation

import ComposableArchitecture
import TCACoordinators

@Reducer
struct TabCoordinator {
    @ObservableState
    struct State: Equatable {
        static let initialState = State(
            map: .initialState,
            explore: .initialState,
            myPage: .initialState,
            selectedTab: .map
        )
        
        var map: MapCoordinator.State
        var explore: ExploreCoordinator.State
        var myPage: MyPageCoordinator.State
        var selectedTab: TabType
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case map(MapCoordinator.Action)
        case explore(ExploreCoordinator.Action)
        case myPage(MyPageCoordinator.Action)
        case tabSelected(TabType)
        
        case routeToLoginScreen
        
        case switchToExploreTab
        
        case routeToRegister
        case routeToEditReview(Int)
        case routeToSettings
        case routeToAttendance
        case routeToEditProfile
        case routeToPost(Int)
        case routeToPostReport(Int)
        case routeToUserReport(Int)
        case routeToRoot
        
        case presentToast(message: String)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Scope(state: \.map, action: \.map) {
            MapCoordinator()
        }
        
        Scope(state: \.explore, action: \.explore) {
            ExploreCoordinator()
        }
        
        Scope(state: \.myPage, action: \.myPage) {
            MyPageCoordinator()
        }
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case let .tabSelected(tab):
                if tab == .register {
                    return .send(.routeToRegister)
                }
                
                state.selectedTab = tab
                return .none
                
            // 탭 이동 액션들
            case .switchToExploreTab:
                state.selectedTab = .explore
                return .none
         
            // map 관련
            case .map(.router(.routeAction(id: _, action: .map(.routeToExploreTab)))):
                return .send(.switchToExploreTab)
                
            case .map(.routeToPostScreen(let postId)):
                return .send(.routeToPost(postId))
            
            // explore 관련
            case .explore(.tabSelected(let tab)):
                return .send(.tabSelected(tab))
                
            case .explore(.routeToPostScreen(let post)):
                return .send(.routeToPost(post))
                
            case .explore(.routeToPostReportScreen(let postId)):
                return .send(.routeToPostReport(postId))
                
            case .explore(.routeToUserReportScreen(let userId)):
                return .send(.routeToUserReport(userId))
                
            case .explore(.routeToEditReviewScreen(let postId)):
                return .send(.routeToEditReview(postId))
                
            case .explore(.presentToast(let message)):
                return .send(.presentToast(message: message))
            
            // mypage 관련
            case .myPage(.router(.routeAction(id: _, action: .profile(.routeToRegister)))):
                return .send(.routeToRegister)
                
            case .myPage(.router(.routeAction(id: _, action: .profile(.routeToEditReviewScreen(let postId))))):
                return .send(.routeToEditReview(postId))
                
            case .myPage(.routeToPostScreen(let postId)):
                return .send(.routeToPost(postId))
                
            case .myPage(.router(.routeAction(id: _, action: .profile(.routeToSettingsScreen)))):
                return .send(.routeToSettings)
                
            case .myPage(.router(.routeAction(id: _, action: .profile(.routeToAttendanceScreen)))):
                return .send(.routeToAttendance)
                
            case .myPage(.router(.routeAction(id: _, action: .profile(.routeToEditProfileScreen)))):
                return .send(.routeToEditProfile)
                
            case .myPage(.routeToLoginScreen):
                return .send(.routeToLoginScreen)
                    
            case .myPage(.router(.routeAction(id: _, action: .otherProfile(.routeToPostReportScreen(let postId))))):
                return .send(.routeToPostReport(postId))
                
            case .myPage(.router(.routeAction(id: _, action: .otherProfile(.routeToUserReportScreen(let userId))))):
                return .send(.routeToUserReport(userId))
                
            case .routeToLoginScreen:
                return .none
                
            case .presentToast:
                return .none
                
            case .routeToRoot:
                state.map.routes = [.root(.map(.initialState), embedInNavigationView: false)]
                state.explore.routes = [.root(.explore(.initialState), embedInNavigationView: false)]
                state.myPage.routes = [.root(.profile(.initialState), embedInNavigationView: false)]
                return .none
                
            default:
                return .none
            }
        }
    }
}

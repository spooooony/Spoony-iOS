//
//  TabCoordinator.swift
//  Spoony-iOS
//
//  Created by 최안용 on 4/1/25.
//

import Foundation

import ComposableArchitecture
import Mixpanel
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
        case changeSelectedTab(TabType)
        
        // MARK: - Route Action: 화면 전환 이벤트를 상위 Reducer에 전달 시 사용
        case delegate(Delegate)
        enum Delegate {
            case routeToLoginScreen
            case routeToRegisterScreen
            case routeToEditReviewScreen(Int)
            case routeToSettingsScreen
            case routeToAttendanceScreen
            case routeToEditProfileScreen
            case routeToPostScreen(Int)
            case routeToPostReportScreen(Int)
            case routeToUserReportScreen(Int)
            case routeToFollowScreen(Int)
            case presentToast(ToastType)
            case presentPopup(PopupType)
        }
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
                    return .send(.delegate(.routeToRegisterScreen))
                } else if tab == .explore {
                    state.explore.routes.goBackToRoot()
                }
                
                Mixpanel.mainInstance().track(
                    event: CommonEvents.Name.tabEntered,
                    properties: CommonEvents.TabEnteredProperty(tabName: tab).dictionary
                )
                
                state.selectedTab = tab
                return .none
            
            case let .map(action):
                switch action {
                case .delegate(let routeAction):
                    switch routeAction {
                    case .routeToPostScreen(let postId):
                        return .send(.delegate(.routeToPostScreen(postId)))
                        
                    case .changeSelectedTab(let tab):
                        return .send(.changeSelectedTab(tab))
                    }
                    
                default:
                    return .none
                }
                
            case let .explore(action):
                switch action {
                case .delegate(let routeAction):
                    switch routeAction {
                    case .changeSelectedTab(let tab):
                        return .send(.changeSelectedTab(tab))
                        
                    case .routeToPostScreen(let postId):
                        return .send(.delegate(.routeToPostScreen(postId)))
                        
                    case .routeToPostReportScreen(let postId):
                        return .send(.delegate(.routeToPostReportScreen(postId)))
                        
                    case .routeToUserReportScreen(let userId):
                        return .send(.delegate(.routeToUserReportScreen(userId)))
                        
                    case .routeToEditReviewScreen(let postId):
                        return .send(.delegate(.routeToEditReviewScreen(postId)))
                        
                    case .routeToReviewDetail(let postId):
                        return .send(.delegate(.routeToPostScreen(postId)))
                        
                    case .routeToFollowScreen(tab: let tab):
                        return .send(.delegate(.routeToFollowScreen(tab)))
                        
                    case .routeToRegisterScreen:
                        return .send(.delegate(.routeToRegisterScreen))
                        
                    case .routeToSettingsScreen:
                        return .send(.delegate(.routeToSettingsScreen))
                        
                    case .routeToAttendanceScreen:
                        return .send(.delegate(.routeToAttendanceScreen))
                        
                    case .routeToEditProfileScreen:
                        return .send(.delegate(.routeToEditProfileScreen))
                        
                    case .presentToast(let type):
                        return .send(.delegate(.presentToast(type)))
                    }
                    
                default:
                    return .none
                }
                
            case let .myPage(action):
                switch action {
                case .delegate(let routeAction):
                    switch routeAction {
                    case .routeToRegisterScreen:
                        return .send(.delegate(.routeToRegisterScreen))
                        
                    case .routeToEditReviewScreen(let postId):
                        return .send(.delegate(.routeToEditReviewScreen(postId)))
                        
                    case .routeToPostScreen(let postId):
                        return .send(.delegate(.routeToPostScreen(postId)))
                        
                    case .routeToLoginScreen:
                        return .send(.delegate(.routeToLoginScreen))
                        
                    case .routeToSettingsScreen:
                        return .send(.delegate(.routeToSettingsScreen))
                        
                    case .routeToEditProfileScreen:
                        return .send(.delegate(.routeToEditProfileScreen))
                        
                    case .routeToAttendanceScreen:
                        return .send(.delegate(.routeToAttendanceScreen))
                        
                    case .routeToPostReportScreen(let postId):
                        return .send(.delegate(.routeToPostReportScreen(postId)))
                        
                    case .routeToUserReportScreen(let userId):
                        return .send(.delegate(.routeToUserReportScreen(userId)))
                        
                    case .routeToReviewDetail(let postId):
                        return .send(.delegate(.routeToPostScreen(postId)))
                        
                    case .routeToFollowScreen(tab: let tab):
                        return .send(.delegate(.routeToFollowScreen(tab)))
                        
                    case .presentPopup(let type):
                        return .send(.delegate(.presentPopup(type)))
                        
                    case .presentToast(let type):
                        return .send(.delegate(.presentToast(type)))
                    }
                    
                default:
                    return .none
                }
                
            case .changeSelectedTab(let tab):
                state.selectedTab = tab
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}

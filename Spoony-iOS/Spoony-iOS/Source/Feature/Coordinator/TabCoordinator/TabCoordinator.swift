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
            register: .initialState,
            myPage: .initialState,
            selectedTab: .map
        )
        
        var map: MapCoordinator.State
        var explore: ExploreCoordinator.State
        var register: RegisterFeature.State
        var myPage: MyPageCoordinator.State
        var selectedTab: TabType
        
        var toast: Toast?
        var popup: PopupType?
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case map(MapCoordinator.Action)
        case explore(ExploreCoordinator.Action)
        case register(RegisterFeature.Action)
        case myPage(MyPageCoordinator.Action)
        case tabSelected(TabType)
        
        // popup 버튼 클릭 시 액션
        case popupAction(PopupType)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Scope(state: \.map, action: \.map) {
            MapCoordinator()
        }
        
        Scope(state: \.explore, action: \.explore) {
            ExploreCoordinator()
        }
        
        Scope(state: \.register, action: \.register) {
            RegisterFeature()
        }
        
        Scope(state: \.myPage, action: \.myPage) {
            MyPageCoordinator()
        }
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case let .tabSelected(tab):
                if state.selectedTab != tab {
                    state.toast = nil
                }
                
                state.selectedTab = tab
                
                return .none
                
            case let .register(.presentToast(message)):
                state.toast = .init(style: .gray, message: message, yOffset: 558.adjustedH)
                return .none
                
            case .explore(.tabSelected(let tab)):
                return .send(.tabSelected(tab))
                
            // 다른 뷰 사용 예시
//            case let .map(.presentToast(message)):
//                state.toast = .init(style: .gray, message: message, yOffset: 558.adjustedH)
//                return .none
//                
            // 자식 Feature에서 presentPopup 호출시 팝업 생성
            case .register(\.presentPopup):
                state.popup = .registerSuccess
                return .none
                
                // 다른 뷰 사용 예시
//            case .map(\.presentPopup):
//                state.popup = .reportSuccess
//                return .none
                                
            case let .popupAction(type):
                switch type {
                case .useSpoon:
                    return .none
                case .reportSuccess:
                    return .none
                case .registerSuccess:
                    // popup 버튼 클릭시 탭 전환이 필요한 경우
                    state.selectedTab = .map
                    
                    // 자식 Feature에서 추가 로직 필요시
                    // ex) return .send(.register(.test))
                    return .none
                }
                
            default:
                return .none
            }
        }
    }
}

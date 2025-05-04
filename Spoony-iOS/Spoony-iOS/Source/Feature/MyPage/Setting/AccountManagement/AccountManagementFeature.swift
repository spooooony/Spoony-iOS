//
//  AccountManagementFeature.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/25/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AccountManagementFeature {
    enum LoginType: Equatable {
        case apple
        case kakao
    }
    
    @ObservableState
    struct State: Equatable {
        static let initialState = State(currentLoginType: .kakao)
        
        var currentLoginType: LoginType
        var logoutAlert: LogoutAlert?
    }
    
    enum LogoutAlert: Equatable {
        case confirmLogout
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case routeToPreviousScreen
        case selectLoginType(LoginType)
        case logoutButtonTapped
        case confirmLogout
        case cancelLogout
        case withdrawButtonTapped
        case routeToWithdrawScreen
        case performLogout
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .routeToPreviousScreen:
                return .none
                
            case let .selectLoginType(type):
                state.currentLoginType = type
                return .none
                
            case .logoutButtonTapped:
                state.logoutAlert = .confirmLogout
                return .none
                
            case .confirmLogout:
                state.logoutAlert = nil
                return .send(.performLogout)
                
            case .cancelLogout:
                state.logoutAlert = nil
                return .none
                
            case .withdrawButtonTapped:
                return .send(.routeToWithdrawScreen)
                
            case .routeToWithdrawScreen:
                return .none
                
            case .performLogout:
                return .none
            }
        }
    }
}

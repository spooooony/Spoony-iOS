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
    }
    
    enum Action {
        case routeToPreviousScreen
        case selectLoginType(LoginType)
        case logoutButtonTapped
        case withdrawButtonTapped
        case routeToLogoutScreen
        case routeToWithdrawScreen
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .routeToPreviousScreen:
                return .none
                
            case let .selectLoginType(type):
                state.currentLoginType = type
                return .none
                
            case .logoutButtonTapped:
                return .send(.routeToLogoutScreen)
                
            case .withdrawButtonTapped:
                return .send(.routeToWithdrawScreen)
                
            case .routeToLogoutScreen, .routeToWithdrawScreen:
                return .none
            }
        }
    }
}

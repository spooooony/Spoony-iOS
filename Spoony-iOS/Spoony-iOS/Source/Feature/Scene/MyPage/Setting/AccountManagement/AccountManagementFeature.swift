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
        var isLoggingOut: Bool = false
        var logoutErrorMessage: String? = nil
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
        case logoutResult(TaskResult<Bool>)
        case routeToLoginScreen
    }
    
    @Dependency(\.authService) var authService: AuthProtocol
    
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
                state.isLoggingOut = true
                state.logoutErrorMessage = nil
                
                return .send(.routeToLoginScreen)
//                return .run { send in
//                    await send(.logoutResult(
//                        TaskResult { try await authService.logout() }
//                    ))
//                }
                
            case let .logoutResult(.success(isSuccess)):
                state.isLoggingOut = false
                if isSuccess {
                    // 토큰 삭제
                    let _ = KeychainManager.delete(key: .accessToken)
                    let _ = KeychainManager.delete(key: .refreshToken)
                    let _ = KeychainManager.delete(key: .socialType)
                    return .send(.routeToLoginScreen)
                } else {
                    state.logoutErrorMessage = "로그아웃에 실패했습니다."
                }
                return .none
                
            case let .logoutResult(.failure(error)):
                state.isLoggingOut = false
                state.logoutErrorMessage = error.localizedDescription
                return .none
                
            case .routeToLoginScreen:
                return .none
            }
        }
    }
}

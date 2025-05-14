//
//  LogoutFeature.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 5/3/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct LogoutFeature {
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
        
        var isLoggingOut: Bool = false
        var showLogoutAlert: Bool = false
        var logoutErrorMessage: String? = nil
    }
    
    enum Action {
        case routeToPreviousScreen
        case logoutButtonTapped
        case confirmLogout
        case cancelLogout
        case logoutResult(TaskResult<Bool>)
        case routeToLoginScreen
        case clearTokenData
    }
    
    @Dependency(\.authService) var authService: AuthProtocol
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            
            switch action {
            case .routeToPreviousScreen:
                return .none
                
            case .logoutButtonTapped:
                state.showLogoutAlert = true
                return .none
                
            case .confirmLogout:
                state.showLogoutAlert = false
                state.isLoggingOut = true
                state.logoutErrorMessage = nil
                                
                return .run { send in
                    await send(.logoutResult(
                        TaskResult { try await authService.logout() }
                    ))
                }
                  
            case .cancelLogout:
                state.showLogoutAlert = false
                return .none
                
            case let .logoutResult(.success(isSuccess)):
                state.isLoggingOut = false
                if isSuccess {
                    return .merge(
                        .send(.clearTokenData),
                        .send(.routeToLoginScreen)
                    )
                } else {
                    state.logoutErrorMessage = "로그아웃에 실패했습니다."
                }
                return .none
                
            case let .logoutResult(.failure(error)):
                state.isLoggingOut = false
                state.logoutErrorMessage = error.localizedDescription
                return .none
                
            case .clearTokenData:
                let accessResult = KeychainManager.delete(key: .accessToken)
                let refreshResult = KeychainManager.delete(key: .refreshToken)
                print("   - Access token deletion: \(accessResult)")
                print("   - Refresh token deletion: \(refreshResult)")
                return .none
                
            case .routeToLoginScreen:
                return .none
            }
        }
    }
}

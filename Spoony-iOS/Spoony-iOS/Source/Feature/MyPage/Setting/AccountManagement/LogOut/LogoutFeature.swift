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
    }
    
    enum Action {
        case routeToPreviousScreen
        case logoutButtonTapped
        case confirmLogout
        case cancelLogout
        case logoutResult(TaskResult<Bool>)
    }
    
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
                
                // 실제 로그아웃 로직 호출
                return .run { send in
                    do {
                        // API 호출 또는 로그아웃 처리 로직
                        // 예: try await userService.logout()
                        try await Task.sleep(nanoseconds: 1_000_000_000) // 1초 지연 (시뮬레이션)
                        await send(.logoutResult(.success(true)))
                    } catch {
                        await send(.logoutResult(.failure(error)))
                    }
                }
                
            case .cancelLogout:
                state.showLogoutAlert = false
                return .none
                
            case let .logoutResult(.success(isSuccess)):
                state.isLoggingOut = false
                if isSuccess {
                    // 로그아웃 성공 시 로그인 화면으로 이동하는 액션
                    // TODO: 로그인 화면으로 이동 구현
                }
                return .none
                
            case let .logoutResult(.failure(error)):
                state.isLoggingOut = false
                print("로그아웃 실패: \(error.localizedDescription)")
                return .none
            }
        }
    }
}

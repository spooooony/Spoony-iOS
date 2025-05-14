//
//  WithdrawFeature.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 5/3/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct WithdrawFeature {
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
        
        var isAgreed: Bool = false
        var isWithdrawing: Bool = false
        var withdrawErrorMessage: String? = nil
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case routeToPreviousScreen
        case toggleAgreement
        case withdrawButtonTapped
        case withdrawResult(TaskResult<Bool>)
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
                
            case .toggleAgreement:
                state.isAgreed.toggle()
                return .none
                
            case .withdrawButtonTapped:
                state.isWithdrawing = true
                state.withdrawErrorMessage = nil
                
                return .run { send in
                    await send(.withdrawResult(
                        TaskResult { try await authService.withdraw() }
                    ))
                }
                
            case let .withdrawResult(.success(isSuccess)):
                state.isWithdrawing = false
                if isSuccess {
                    let _ = KeychainManager.delete(key: .accessToken)
                    let _ = KeychainManager.delete(key: .refreshToken)
                    
                    UserManager.shared.clearAllUserDefaults()
                    
                    return .send(.routeToLoginScreen)
                }
                return .none
                
            case let .withdrawResult(.failure(error)):
                state.isWithdrawing = false
                state.withdrawErrorMessage = error.localizedDescription
                print("회원탈퇴 실패: \(error.localizedDescription)")
                return .none
                
            case .routeToLoginScreen:
                return .none
            }
        }
    }
}

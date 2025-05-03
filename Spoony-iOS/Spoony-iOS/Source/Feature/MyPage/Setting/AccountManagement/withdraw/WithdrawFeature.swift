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
        
        var isWithdrawing: Bool = false
        var showWithdrawAlert: Bool = false
        var isAgreed: Bool = false
    }
    
    enum Action {
        case routeToPreviousScreen
        case toggleAgreement
        case withdrawButtonTapped
        case confirmWithdraw
        case cancelWithdraw
        case withdrawResult(TaskResult<Bool>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .routeToPreviousScreen:
                return .none
                
            case .toggleAgreement:
                state.isAgreed.toggle()
                return .none
                
            case .withdrawButtonTapped:
                state.showWithdrawAlert = true
                return .none
                
            case .confirmWithdraw:
                state.showWithdrawAlert = false
                state.isWithdrawing = true
                
                // 실제 회원 탈퇴 로직 호출
                return .run { send in
                    do {
                        // API 호출 또는 회원 탈퇴 처리 로직
                        // 예: try await userService.withdraw()
                        try await Task.sleep(nanoseconds: 1_000_000_000) // 1초 지연 (시뮬레이션)
                        await send(.withdrawResult(.success(true)))
                    } catch {
                        await send(.withdrawResult(.failure(error)))
                    }
                }
                
            case .cancelWithdraw:
                state.showWithdrawAlert = false
                return .none
                
            case let .withdrawResult(.success(isSuccess)):
                state.isWithdrawing = false
                if isSuccess {
                    // 탈퇴 성공 시 로그인 화면으로 이동하는 액션
                    // TODO: 로그인 화면으로 이동 구현
                }
                return .none
                
            case let .withdrawResult(.failure(error)):
                state.isWithdrawing = false
                print("회원 탈퇴 실패: \(error.localizedDescription)")
                return .none
            }
        }
    }
}

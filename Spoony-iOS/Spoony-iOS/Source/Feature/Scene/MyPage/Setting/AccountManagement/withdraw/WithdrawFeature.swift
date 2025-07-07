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
    enum WithdrawAlert: Equatable {
        case confirmWithdraw
    }
    
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
        
        var isAgreed: Bool = false
        var withdrawAlert: WithdrawAlert? = nil
        var isWithdrawing: Bool = false
        var withdrawErrorMessage: String? = nil
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case routeToPreviousScreen
        case toggleAgreement
        case withdrawButtonTapped
        case confirmWithdraw
        case cancelWithdraw
        case performWithdraw
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
                state.withdrawAlert = .confirmWithdraw
                return .none
                
            case .confirmWithdraw:
                state.withdrawAlert = nil
                return .send(.performWithdraw)
                
            case .cancelWithdraw:
                state.withdrawAlert = nil
                return .none
                
            case .performWithdraw:
                state.isWithdrawing = true
                state.withdrawErrorMessage = nil
                
                // 실제 회원탈퇴 API 호출
                return .run { send in
                    await send(.withdrawResult(
                        TaskResult { try await authService.withdraw() }
                    ))
                }
                
            case let .withdrawResult(.success(isSuccess)):
                state.isWithdrawing = false
                print("🔍 WithdrawFeature: API 응답 성공, isSuccess = \(isSuccess)")

                if isSuccess {
                    // 회원탈퇴 성공 시 모든 데이터 클리어
                    let _ = KeychainManager.delete(key: .accessToken)
                    let _ = KeychainManager.delete(key: .refreshToken)
                    // socialType 제거 (존재하지 않는 키)
                    
                    // UserDefaults 클리어
                    UserDefaults.standard.removeObject(forKey: "userId")
                    
                    // UserManager의 데이터 클리어
                    UserManager.shared.userId = nil
                    UserManager.shared.recentSearches = nil
                    UserManager.shared.exploreUserRecentSearches = nil
                    UserManager.shared.exploreReviewRecentSearches = nil
                    
                    print("✅ 회원탈퇴 성공 - 모든 데이터 정리 완료")
                    return .send(.routeToLoginScreen)
                } else {
                    state.withdrawErrorMessage = "회원탈퇴에 실패했습니다."
                    print("❌ 회원탈퇴 실패 - API에서 false 반환")
                }
                return .none
                
            case let .withdrawResult(.failure(error)):
                state.isWithdrawing = false
                state.withdrawErrorMessage = error.localizedDescription
                print("❌ 회원탈퇴 API 호출 실패: \(error.localizedDescription)")
                return .send(.routeToLoginScreen)

            case .routeToLoginScreen:
                print("🔄 로그인 화면으로 이동 요청")
                return .none
            }
        }
    }
}

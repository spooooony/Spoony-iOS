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
        case unknown
        
        static func from(platform: String) -> LoginType {
            switch platform.uppercased() {
            case "APPLE":
                return .apple
            case "KAKAO":
                return .kakao
            default:
                return .unknown
            }
        }
    }
    
    @ObservableState
    struct State: Equatable {
        static let initialState = State(currentLoginType: .kakao)
        
        var currentLoginType: LoginType
        var isAlertPresented: Bool = false
        var isLoggingOut: Bool = false
        var logoutErrorMessage: String? = nil
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case userInfoResponse(TaskResult<UserInfoResponse>)
        case selectLoginType(LoginType)
        case logoutButtonTapped
        case confirmLogout
        case cancelLogout
        case withdrawButtonTapped
        case performLogout
        case logoutResult(TaskResult<Bool>)
        
        // MARK: - Route Action: 화면 전환 이벤트를 상위 Reducer에 전달 시 사용
        case delegate(Delegate)
        enum Delegate {
            case routeToWithdrawScreen
            case routeToPreviousScreen
            case routeToLoginScreen
        }
    }
    
    @Dependency(\.authService) var authService: AuthProtocol
    @Dependency(\.myPageService) var myPageService: MypageServiceProtocol
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .onAppear:
                return .run { send in
                    await send(.userInfoResponse(
                        TaskResult { try await myPageService.getUserInfo() }
                    ))
                }
                
            case let .userInfoResponse(.success(response)):
                state.currentLoginType = LoginType.from(platform: response.platform)
                return .none
                
            case let .userInfoResponse(.failure(error)):
                print("Error fetching user info: \(error.localizedDescription)")
                return .none
                
            case let .selectLoginType(type):
                state.currentLoginType = type
                return .none
                
            case .logoutButtonTapped:
                state.isAlertPresented = true
                return .none
                
            case .confirmLogout:
                state.isAlertPresented = false
                return .send(.performLogout)
                
            case .cancelLogout:
                state.isAlertPresented = false
                return .none
                
            case .withdrawButtonTapped:
                return .send(.delegate(.routeToWithdrawScreen))
                
            case .performLogout:
                state.isLoggingOut = true
                state.logoutErrorMessage = nil
                
                return .run { send in
                       await send(.logoutResult(
                           TaskResult { try await authService.logout() }
                       ))
                   }
                
            case let .logoutResult(.success(isSuccess)):
                state.isLoggingOut = false
                if isSuccess {
                    // 모든 인증 정보 삭제
                    let _ = KeychainManager.delete(key: .accessToken)
                    let _ = KeychainManager.delete(key: .refreshToken)
                    
                    // UserDefaults 초기화
                    UserDefaults.standard.removeObject(forKey: "userId")
                    
                    // UserManager 초기화
                    UserManager.shared.userId = nil
                    UserManager.shared.recentSearches = nil
                    UserManager.shared.exploreUserRecentSearches = nil
                    UserManager.shared.exploreReviewRecentSearches = nil
                    
                    return .send(.delegate(.routeToLoginScreen))
                } else {
                    state.logoutErrorMessage = "로그아웃에 실패했습니다."
                }
                return .none
                
            case let .logoutResult(.failure(error)):
                state.isLoggingOut = false
                state.logoutErrorMessage = error.localizedDescription
                print("로그아웃 실패: \(error.localizedDescription)")
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}

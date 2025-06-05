//
//  LoginFeature.swift
//  Spoony-iOS
//
//  Created by 최주리 on 3/12/25.
//

import Foundation

import ComposableArchitecture

enum SocialType: String {
    case KAKAO
    case APPLE
    
    static func from(rawValue: String) -> SocialType? {
        return SocialType(rawValue: rawValue)
    }
}

enum LoginError: Error {
    case kakaoTokenError
    case appleTokenError
    case serverLoginError
}

@Reducer
struct LoginFeature {
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
        
        var socialType: SocialType = .KAKAO
        var token: String = ""
        var isLoading: Bool = false
    }
    
    enum Action {
        case tempHomeButtonTapped
        
        case onAppear
        case kakaoLoginButtonTapped
        case appleLoginButtonTapped
        case login(SocialType, String)

        case error(Error)
        
        // MARK: Navigation Action
        case routToTermsOfServiceScreen
        case routToTabCoordinatorScreen
        case presentToast(message: String)
    }
        
    private let authenticationManager = AuthenticationManager.shared
    @Dependency(\.socialLoginService) var socialLoginService: SocialLoginServiceProtocol
    @Dependency(\.authService) var authService: AuthProtocol
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .tempHomeButtonTapped:
                return .send(.routToTabCoordinatorScreen)
            case .onAppear:
//                if authenticationManager.checkAutoLogin() {
//                    return .send(.routToTabCoordinatorScreen)
//                } else {
//                    return .none
//                }
                return .none
            case .kakaoLoginButtonTapped:
                state.isLoading = true
                
                return .run { send in
                    do {
                        let result = try await socialLoginService.kakaoLogin()
                        authenticationManager.setToken(.KAKAO, result)
                        await send(.login(.KAKAO, result))
                    } catch {
                        await send(.error(LoginError.kakaoTokenError))
                    }
                }
            case .appleLoginButtonTapped:
                state.isLoading = true
                
                return .run { send in
                    do {
                        let result = try await socialLoginService.appleLogin()
                        authenticationManager.setToken(.APPLE, result)
                        await send(.login(.APPLE, result))
                    } catch {
                        await send(.error(LoginError.appleTokenError))
                    }
                }
            case .login(let type, let token):
                return .run { send in
                    do {
                        let isExists = try await authService.login(platform: type.rawValue, token: token)
                        if isExists {
//                            authenticationManager.setAuthenticationState()
                            await send(.routToTabCoordinatorScreen)
                        } else {
                            await send(.routToTermsOfServiceScreen)
                        }
                    } catch {
                        await send(.error(LoginError.serverLoginError))
                    }
                }
            case .error(let error):
                #if DEBUG
                print(error.localizedDescription)
                #endif
                
                state.isLoading = false
                return .send(.presentToast(message: "서버에 연결할 수 없습니다.\n잠시 후 다시 시도해 주세요."))
                
            // 회원 가입 Flow
            case .routToTermsOfServiceScreen:
                state.isLoading = false
                return .none
            // 로그인 성공
            case .routToTabCoordinatorScreen:
                state.isLoading = false
                return .none
            case .presentToast:
                return .none
            }
        }
    }
}

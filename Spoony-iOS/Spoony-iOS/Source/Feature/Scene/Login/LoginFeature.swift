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
        case routToOnboardingScreen
        case routToTabCoordinatorScreen
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
                //자동 로그인시
//                return .send(.routToTabCoordinatorScreen)
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
                            await send(.routToTabCoordinatorScreen)
                        } else {
                            await send(.routToTermsOfServiceScreen)
                        }
                    } catch {
                        await send(.error(LoginError.serverLoginError))
                    }
                }
            case .error(let error):
                print(error.localizedDescription)
                state.isLoading = false
                return .none
                
            // 로그인 성공시(약관 동의 안한 경우)
            case .routToTermsOfServiceScreen:
                state.isLoading = false
                return .none
            // 로그인 완료시(앱 삭제 후 다시 로그인한 경우? 삭제하면 어차피 약관 동의도 다시 하지 않나 필요없을지도)
            case .routToOnboardingScreen:
                return .none
            // 로그인 성공시
            case .routToTabCoordinatorScreen:
                state.isLoading = false
                return .none
            }
        }
    }
}

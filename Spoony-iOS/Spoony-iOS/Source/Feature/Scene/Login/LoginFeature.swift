//
//  LoginFeature.swift
//  Spoony-iOS
//
//  Created by 최주리 on 3/12/25.
//

import Foundation

import ComposableArchitecture
import Mixpanel

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
    }
    
    enum Action {
        case tempHomeButtonTapped
        
        case onAppear
        case kakaoLoginButtonTapped
        case appleLoginButtonTapped
        case login(SocialType, String)

        case error(Error)
        
        // MARK: - Route Action: 화면 전환 이벤트를 상위 Reducer에 전달 시 사용
        case delegate(Delegate)
        enum Delegate {
            case routeToTermsOfServiceScreen
            case routeToTabCoordinatorScreen
            case presentToast(ToastType)
        }
    }
        
    private let authenticationManager = AuthenticationManager.shared
    @Dependency(\.socialLoginService) var socialLoginService: SocialLoginServiceProtocol
    @Dependency(\.authService) var authService: AuthProtocol
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .tempHomeButtonTapped:
                return .send(.delegate(.routeToTabCoordinatorScreen))
            case .onAppear:
                if authenticationManager.checkAutoLogin() {
                    Mixpanel.mainInstance().track(
                        event: ConversionAnalysisEvents.Name.loginsuccess
                    )
                    
                    if let userId = UserManager.shared.userId {
                        Mixpanel.mainInstance().identify(distinctId: "\(userId)")
                    }
                    
                    return .send(.delegate(.routeToTabCoordinatorScreen))
                } else {
                    return .none
                }
            case .kakaoLoginButtonTapped:
                return .run { send in
                    do {
                        let result = try await socialLoginService.kakaoLogin()
                        authenticationManager.setToken(.KAKAO, result)
                        await send(.login(.KAKAO, result))
                    } catch {
//                        await send(.error(LoginError.kakaoTokenError))
                    }
                }
            case .appleLoginButtonTapped:
                return .run { send in
                    do {
                        let result = try await socialLoginService.appleLogin()
                        authenticationManager.setToken(.APPLE, result)
                        await send(.login(.APPLE, result))
                    } catch {
//                        await send(.error(LoginError.appleTokenError))
                    }
                }
            case .login(let type, let token):
                return .run { send in
                    do {
                        let isExists = try await authService.login(platform: type.rawValue, token: token)
                        if isExists {
                            Mixpanel.mainInstance().track(
                                event: ConversionAnalysisEvents.Name.loginsuccess
                            )
                            await send(.delegate(.routeToTabCoordinatorScreen))
                        } else {
                            Mixpanel.mainInstance().track(
                                event: ConversionAnalysisEvents.Name.signupCompleted,
                                properties: ConversionAnalysisEvents.SignupProperty(method: type).dictionary
                            )
                            await send(.delegate(.routeToTermsOfServiceScreen))
                        }
                    } catch {
                        await send(.error(LoginError.serverLoginError))
                    }
                }
                
            case .error(let error):
                #if DEBUG
                print(error.localizedDescription)
                #endif
                
                return .send(.delegate(.presentToast(.serverError)))
                
            case .delegate:
                return .none
            }
        }
    }
}

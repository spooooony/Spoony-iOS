//
//  LoginFeature.swift
//  Spoony-iOS
//
//  Created by 최주리 on 3/12/25.
//

import Foundation

import ComposableArchitecture

enum SocialType {
    case KAKAO
    case APPLE
}

enum LoginError: Error {
    case kakaoTokenError
    case appleTokenError
}

@Reducer
struct LoginFeature {
    
    @ObservableState
    struct State {
        var socialType: SocialType = .KAKAO
        var token: String = ""
    }
    
    enum Action {
        case onAppear
        case kakaoLoginButtonTapped
        case appleLoginButtonTapped
        case setToken(SocialType, String)
        case error(Error)
    }
    
    @Dependency(\.loginService) var loginService: LoginServiceProtocol
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .kakaoLoginButtonTapped:
                return .run { send in
                    do {
                        let result = try await loginService.kakaoLogin()
                        await send(.setToken(.KAKAO, result))
                    } catch {
                        await send(.error(LoginError.kakaoTokenError))
                    }
                }
            case .appleLoginButtonTapped:
                return .run { send in
                    loginService.appleLogin()
                }
            case .setToken(let type, let token):
                state.socialType = type
                state.token = token
                return .none
            case .error(let error):
                print(error.localizedDescription)
                return .none
            }
        }
    }
}

private enum LoginServiceKey: DependencyKey {
    static let liveValue: LoginServiceProtocol = DefaultLoginService()
}

extension DependencyValues {
    var loginService: LoginServiceProtocol {
        get { self[LoginServiceKey.self] }
        set { self[LoginServiceKey.self] = newValue }
    }
}

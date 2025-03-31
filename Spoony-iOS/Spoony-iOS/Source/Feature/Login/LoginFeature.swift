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
        var isLoading: Bool = false
    }
    
    enum Action {
        case onAppear
        case kakaoLoginButtonTapped
        case appleLoginButtonTapped
        case setToken(SocialType, String)
        case error(Error)
    }
    
    let navigationManager: AuthNavigationManager
    private let authenticationManager = AuthenticationManager.shared
    @Dependency(\.loginService) var loginService: LoginServiceProtocol
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .kakaoLoginButtonTapped:
                state.isLoading = true
                
                return .run { send in
                    do {
                        let result = try await loginService.kakaoLogin()
                        await send(.setToken(.KAKAO, result))
                    } catch {
                        await send(.error(LoginError.kakaoTokenError))
                    }
                }
            case .appleLoginButtonTapped:
                state.isLoading = true
                
                return .run { send in
                    do {
                        let result = try await loginService.appleLogin()
                        await send(.setToken(.APPLE, result))
                    } catch {
                        await send(.error(LoginError.appleTokenError))
                    }
                }
            case .setToken(let type, let token):
                authenticationManager.setToken(type, token)
                state.isLoading = false
                navigationManager.push(.agreeView)
                return .none
            case .error(let error):
                print(error.localizedDescription)
                state.isLoading = false
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

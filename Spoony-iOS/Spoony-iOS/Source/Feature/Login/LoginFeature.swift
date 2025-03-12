//
//  LoginFeature.swift
//  Spoony-iOS
//
//  Created by 최주리 on 3/12/25.
//

import Foundation

import ComposableArchitecture

@Reducer
struct LoginFeature {
    
    @ObservableState
    struct State {
        
    }
    
    enum Action {
        case onAppear
        case kakaoLoginButtonTapped
        case appleLoginButtonTapped
    }
    
    @Dependency(\.loginService) var loginService: LoginServiceProtocol
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .kakaoLoginButtonTapped:
                return .run { send in
                    loginService.kakaoLogin()
                }
            case .appleLoginButtonTapped:
                return .run { send in
                    loginService.appleLogin()
                }
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

//
//  AuthenticationFeature.swift
//  Spoony-iOS
//
//  Created by 최주리 on 3/25/25.
//

import ComposableArchitecture

enum AuthenticationState {
    case authenticated
    case unAuthenticated
}

@Reducer
struct AuthenticationFeature {
    
    @ObservableState
    struct State {
        var loginState: LoginFeature.State
        
        var authenticationState: AuthenticationState = .unAuthenticated
        var kakaoToken: String?
        var appleToken: String?
    }
    
    enum Action {
        case viewAppear
//        case loginAction(LoginFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewAppear:
                checkAuthentication()
                return .none
//            case .loginAction(.kakaoLoginButtonTapped):
//                state.kakaoToken = state.loginState.token
//            case .loginAction:
//                return .none
            }
        }
    }
    
    private func checkAuthentication() {
        // 자동로그인 여부 확인
    }
}

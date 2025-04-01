//
//  AuthenticationManager.swift
//  Spoony-iOS
//
//  Created by 최주리 on 3/25/25.
//

import Foundation

import ComposableArchitecture

enum AuthenticationState {
    case authenticated
    case unAuthenticated
}

final class AuthenticationManager {
    static let shared = AuthenticationManager()
    
    private init() { }
    
    @Published private(set) var authenticationState: AuthenticationState = .unAuthenticated
    private(set) var socialToken: String?
    private(set) var socialType: SocialType = .KAKAO
    
    func setToken(_ type: SocialType, _ token: String) {
        self.socialType = type
        self.socialToken = token
    }
    
    func checkAuthentication() {
        // 자동로그인 여부 확인
    }
}

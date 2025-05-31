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
    
    func checkAutoLogin() -> (SocialType, String)? {
        switch KeychainManager.read(key: .socialType) {
        case .success(let type):
            guard let type else { return nil }
            self.socialType = SocialType.from(rawValue: type) ?? .KAKAO
        case .failure:
            print("⛔️ 자동 로그인 실패")
            return nil
        }
        
        switch KeychainManager.read(key: .accessToken) {
        case .success(let token):
            guard let token else { return nil }
            self.socialToken = token
        case .failure:
            print("⛔️ 자동 로그인 실패")
            return nil
        }
        
        return (self.socialType, self.socialToken ?? "")
    }
}

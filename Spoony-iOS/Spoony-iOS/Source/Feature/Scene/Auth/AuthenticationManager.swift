//
//  AuthenticationManager.swift
//  Spoony-iOS
//
//  Created by 최주리 on 3/25/25.
//

import Foundation

import ComposableArchitecture

final class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    private init() { }
    
    private(set) var socialToken: String?
    private(set) var socialType: SocialType = .KAKAO
    
    func setToken(_ type: SocialType, _ token: String) {
        self.socialType = type
        self.socialToken = token
    }
    
    func checkAutoLogin() -> Bool {
        switch KeychainManager.read(key: .socialType) {
        case .success(let type):
            guard let type else { return false }
            self.socialType = SocialType.from(rawValue: type) ?? .KAKAO
        case .failure:
            print("⛔️ 자동 로그인 실패")
            return false
        }
        
        switch KeychainManager.read(key: .accessToken) {
        case .success(let token):
            guard let token else { return false }
            self.socialToken = token
        case .failure:
            print("⛔️ 자동 로그인 실패")
            return false
        }
        
        return true
    }
}

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
    private(set) var appleCode: String?
    
    func setToken(_ type: SocialType, _ token: String, _ code: String? = nil) {
        self.socialType = type
        self.socialToken = token
        self.appleCode = code
    }
    
    func checkAutoLogin() -> Bool {
        let social = KeychainManager.read(key: .socialType)
        self.socialType = SocialType.from(rawValue: social ?? "") ?? .KAKAO
        
        let token = KeychainManager.read(key: .accessToken)
        self.socialToken = token
        
        if token == nil {
            print("⛔️자동 로그인 실패")
            return false
        }
        
        return true
    }
}

//
//  TokenManager.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 6/5/25.
//

import Foundation

class TokenManager {
    static let shared = TokenManager()
    private init() {}
    
    var currentToken: String? {
        switch KeychainManager.read(key: .accessToken) {
        case .success(let token):
            return token
        case .failure:
            return nil
        }
    }
    
    var currentRefreshToken: String? {
        switch KeychainManager.read(key: .refreshToken) {
        case .success(let token):
            return token
        case .failure:
            return nil
        }
    }
}

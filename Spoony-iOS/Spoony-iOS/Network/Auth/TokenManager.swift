//
//  TokenManager.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 6/5/25.
//

import Foundation

final class TokenManager {
    static let shared = TokenManager()
    private init() {}
    
    var currentToken: String? {
        return KeychainManager.read(key: .accessToken)
    }
    
    var currentRefreshToken: String? {
        return KeychainManager.read(key: .refreshToken)
    }
}

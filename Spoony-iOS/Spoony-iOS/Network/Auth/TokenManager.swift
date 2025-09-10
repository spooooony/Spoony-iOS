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
    
    private var cachedAccessToken: String?
    private var cachedRefreshToken: String?
    
    var currentToken: String? {
        cachedAccessToken ?? {
            let token = KeychainManager.read(key: .accessToken)
            cachedAccessToken = token
            return token
        }()
    }
    
    var currentRefreshToken: String? {
        cachedRefreshToken ?? {
            let token = KeychainManager.read(key: .refreshToken)
            cachedRefreshToken = token
            return token
        }()
    }
    
    func updateTokens(accessToken: String, refreshToken: String) {
        _ = KeychainManager.create(key: .accessToken, value: accessToken)
        _ = KeychainManager.create(key: .refreshToken, value: refreshToken)
        
        cachedAccessToken = accessToken
        cachedRefreshToken = refreshToken
    }
    
    func deleteTokens() {
        _ = KeychainManager.delete(key: .accessToken)
        _ = KeychainManager.delete(key: .refreshToken)
        _ = KeychainManager.delete(key: .socialType)
        
        cachedAccessToken = nil
        cachedRefreshToken = nil
    }
}

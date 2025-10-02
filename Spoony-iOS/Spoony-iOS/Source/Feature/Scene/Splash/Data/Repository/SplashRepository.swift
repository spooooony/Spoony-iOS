//
//  SplashRepository.swift
//  Spoony
//
//  Created by 최주리 on 10/2/25.
//

import Foundation

struct SplashRepository: SplashInterface {
    private let service: RefreshProtocol
    
    init(service: RefreshProtocol) {
        self.service = service
    }
    
    func checkAutoLogin() -> Bool {
        if let _ = KeychainManager.read(key: .accessToken) else {
            return true
        } else {
            return false
        }
    }
    
    func refresh() async throws {
        let refreshToken = TokenManager.shared.currentRefreshToken
        let result = try await service.refresh(token: refreshToken ?? "")

        TokenManager.shared.updateTokens(
            accessToken: result.accessToken,
            refreshToken: result.refreshToken
        )
    }
}

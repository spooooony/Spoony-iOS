//
//  RefreshService.swift
//  Spoony-iOS
//
//  Created by 최주리 on 5/30/25.
//

import Foundation

protocol RefreshProtocol {
    func refresh(token: String) async throws -> TokenCredential
}

final class DefaultRefreshService: RefreshProtocol {
    static let shared = DefaultRefreshService()
    
    private init() { }
    
    private let provider = Providers.authProvider
    
    func refresh(token: String) async throws -> TokenCredential {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.refresh(token: token)) { result in
                switch result {
                case .success(let response):
                    do {
                        let dto = try response.map(BaseResponse<RefreshResponse>.self)
                        guard let dto = dto.data else {
                            continuation.resume(throwing: SNError.noData)
                            return
                        }
                        
                        KeychainManager.saveKeychain(
                            access: dto.accessToken,
                            refresh: dto.refreshToken,
                            platform: AuthenticationManager.shared.socialType.rawValue
                        )
                        let tokenSet: TokenCredential = .init(
                            accessToken: dto.accessToken,
                            refreshToken: dto.refreshToken
                        )
                        continuation.resume(returning: tokenSet)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

final class MockRefreshService: RefreshProtocol {
    func refresh(token: String) async throws -> TokenCredential {
        return TokenCredential(accessToken: "", refreshToken: "")
    }
}

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
    
    let provider = Providers.authProvider
    
    private func saveKeychain(access: String, refresh: String) {
        switch KeychainManager.create(key: .accessToken, value: access) {
        case .success:
            print("✅ Access Token saved successfully")
        case .failure(let error):
            print("❌ Access Token save failed: \(error)")
        }
        
        switch KeychainManager.create(key: .refreshToken, value: refresh) {
        case .success:
            print("✅ Refresh Token saved successfully")
        case .failure(let error):
            print("❌ Refresh Token save failed: \(error)")
        }
        
        // 저장 후 바로 읽어보기 테스트
        switch KeychainManager.read(key: .accessToken) {
        case .success(let token):
            print("✅ Access Token read test: \(token?.prefix(30) ?? "nil")")
        case .failure(let error):
            print("❌ Access Token read test failed: \(error)")
        }
    }
    
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
                        
                        self.saveKeychain(access: dto.accessToken, refresh: dto.refreshToken)
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

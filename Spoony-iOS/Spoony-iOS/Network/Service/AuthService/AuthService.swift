//
//  AuthService.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/22/25.
//

import Foundation

protocol AuthProtocol {
    func login(platform: String, token: String) async throws -> Bool
}

final class DefaultAuthService: AuthProtocol {
    let provider = Providers.authProvider
    
    func login(platform: String, token: String) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            
            provider.request(.login(platfomr: platform, token: token)) { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let response):
                    do {
                        let dto = try response.map(BaseResponse<LoginResponse>.self)
                        guard let data = dto.data
                        else {
                            continuation.resume(throwing: APIAuthError.noData)
                            return
                        }
                        
                        self.saveKeychain(
                            access: data.jwtTokenDto.accessToken,
                            refresh: data.jwtTokenDto.refreshToken
                        )
                        continuation.resume(returning: data.exists)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func saveKeychain(access: String, refresh: String) {
        if case .failure(let error) = KeychainManager.create(
            key: .accessToken, value: access
        ) {
            print("Keychain Create Error: \(error)")
        }
        
        if case .failure(let error) = KeychainManager.create(
            key: .refreshToken, value: refresh
        ) {
            print("Keychain Create Error: \(error)")
        }
    }
}

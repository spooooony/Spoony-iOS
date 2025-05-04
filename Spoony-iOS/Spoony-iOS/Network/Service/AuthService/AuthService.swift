//
//  AuthService.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/22/25.
//

import Foundation

protocol AuthProtocol {
    func login(platform: String, token: String) async throws -> Bool
    func signup(
        platform: String,
        userName: String,
        birth: String?,
        regionId: Int?,
        introduction: String?
    ) async throws -> OnboardingUserEntity
}

final class DefaultAuthService: AuthProtocol {
    let provider = Providers.authProvider
    
    func login(platform: String, token: String) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            
            provider.request(.login(platform: platform, token: token)) { [weak self] result in
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
    
    func signup(
        platform: String,
        userName: String,
        birth: String?,
        regionId: Int?,
        introduction: String?
    ) async throws -> OnboardingUserEntity {
        return try await withCheckedThrowingContinuation { continuation in
            let request: SignupRequest = .init(
                platform: platform,
                userName: userName,
                birth: birth,
                regionId: regionId,
                introduction: introduction
            )
            provider.request(.signup(request)) { result in
                switch result {
                case .success(let response):
                    do {
                        let dto = try response.map(BaseResponse<SignupResponse>.self)
                        guard let data = dto.data
                        else {
                            continuation.resume(throwing: APIAuthError.noData)
                            return
                        }
                        
                        let user = data.user.toEntity()
                        continuation.resume(returning: user)
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

final class MockAuthService: AuthProtocol {
    func login(platform: String, token: String) async throws -> Bool {
        return false
    }
    
    func signup(platform: String, userName: String, birth: String?, regionId: Int?, introduction: String?) async throws -> OnboardingUserEntity {
        return .init(
            userName: "주리부리",
            region: nil,
            introduction: nil,
            birth: nil
        )
    }
}

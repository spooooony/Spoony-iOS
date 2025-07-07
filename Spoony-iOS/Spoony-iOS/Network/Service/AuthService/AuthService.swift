//
//  AuthService.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/22/25.
//

import Foundation

import Mixpanel

protocol AuthProtocol {
    func login(platform: String, token: String) async throws -> Bool
    func signup(
        platform: String,
        userName: String,
        birth: String?,
        regionId: Int?,
        introduction: String?,
        token: String
    ) async throws -> String
    func nicknameDuplicateCheck(userName: String) async throws -> Bool
    func getRegionList() async throws -> RegionListResponse
    func logout() async throws -> Bool
    func withdraw() async throws -> Bool
}

final class DefaultAuthService: AuthProtocol {
    let provider = Providers.authProvider
    let myPageProvider = Providers.myPageProvider
    
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
                            continuation.resume(throwing: SNError.noData)
                            return
                        }
                        
                        if let token = data.jwtTokenDto {
                            KeychainManager.saveKeychain(
                                access: token.accessToken,
                                refresh: token.refreshToken,
                                platform: platform
                            )
                        }
                        
                        if let userId = UserManager.shared.userId {
                            Mixpanel.mainInstance().identify(distinctId: "\(userId)")
                        }
                        
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
        introduction: String?,
        token: String
    ) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let request: SignupRequest = .init(
                platform: platform,
                userName: userName,
                birth: birth,
                regionId: regionId,
                introduction: introduction
            )
            provider.request(.signup(request, token: token)) { result in
                switch result {
                case .success(let response):
                    do {
                        let dto = try response.map(BaseResponse<SignupResponse>.self)
                        guard let data = dto.data
                        else {
                            continuation.resume(throwing: SNError.noData)
                            return
                        }
                        UserManager.shared.userId = data.user.userId
                        Mixpanel.mainInstance().identify(distinctId: "\(data.user.userId)")
                        
                        let user = data.user.userName
                        let token = data.jwtTokenDto
                        KeychainManager.saveKeychain(
                            access: token.accessToken,
                            refresh: token.refreshToken,
                            platform: platform
                        )
                        
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
    
    func nicknameDuplicateCheck(userName: String) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            myPageProvider.request(.nicknameDuplicateCheck(query: userName)) { result in
                switch result {
                case .success(let response):
                    do {
                        let dto = try response.map(BaseResponse<Bool>.self)
                        guard let data = dto.data
                        else {
                            continuation.resume(throwing: SNError.noData)
                            return
                        }
                        
                        continuation.resume(returning: data)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getRegionList() async throws -> RegionListResponse {
        return try await withCheckedThrowingContinuation { continuation in
            myPageProvider.request(.getUserRegion) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<RegionListResponse>.self)
                        guard let data = responseDto.data else { return }
                        
                        continuation.resume(returning: data)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func logout() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.logout) { result in
                switch result {
                case .success(let response):
                    do {
                        let dto = try response.map(BaseResponse<BlankData>.self)
                        continuation.resume(returning: dto.success)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func withdraw() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.withdraw) { result in
                switch result {
                case .success(let response):
                    do {
                        let dto = try response.map(BaseResponse<BlankData>.self)
                        continuation.resume(returning: dto.success)
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

final class MockAuthService: AuthProtocol {
    func login(platform: String, token: String) async throws -> Bool {
        return false
    }
    
    func signup(
        platform: String,
        userName: String,
        birth: String?,
        regionId: Int?,
        introduction: String?,
        token: String
    ) async throws -> String {
        return "nickname"
    }
    
    func nicknameDuplicateCheck(userName: String) async throws -> Bool {
        return false
    }
    
    func getRegionList() async throws -> RegionListResponse {
        return .init(regionList: [])
    }
    
    func logout() async throws -> Bool {
        return true
    }
    
    func withdraw() async throws -> Bool {
        return true
    }
}

//
//  AuthService.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/22/25.
//

import Foundation

import Mixpanel

protocol AuthProtocol {
    func login(platform: String, token: String, code: String?) async throws -> Bool
    func signup(
        platform: String,
        userName: String,
        birth: String?,
        regionId: Int?,
        introduction: String?,
        token: String,
        code: String?
    ) async throws -> String
    func nicknameDuplicateCheck(userName: String) async throws -> Bool
    func getRegionList() async throws -> RegionListResponse
    func logout() async throws -> Bool
    func withdraw() async throws -> Bool
}

final class DefaultAuthService: AuthProtocol {
    let provider = Providers.authProvider
    let myPageProvider = Providers.myPageProvider
    
    func login(platform: String, token: String, code: String?) async throws -> Bool {
        do {
            let result = try await provider.request(.login(platform: platform, token: token, code: code))
                .map(to: BaseResponse<LoginResponse>.self)
            
            guard let data = result.data else {
                throw SNError.noData
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
            
            return data.exists
        } catch {
            throw error
        }
    }
    
    func signup(
        platform: String,
        userName: String,
        birth: String?,
        regionId: Int?,
        introduction: String?,
        token: String,
        code: String? = nil
    ) async throws -> String {
        do {
            let request: SignupRequest = .init(
                platform: platform,
                userName: userName,
                birth: birth,
                regionId: regionId,
                introduction: introduction,
                authCode: code
            )
            
            let result = try await provider.request(.signup(request, token: token))
                .map(to: BaseResponse<SignupResponse>.self)
            
            guard let data = result.data else {
                throw SNError.noData
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
            
            return user
        } catch {
            throw error
        }
    }
    
    func nicknameDuplicateCheck(userName: String) async throws -> Bool {
        do {
            let result = try await myPageProvider.request(.nicknameDuplicateCheck(query: userName))
                .map(to: BaseResponse<Bool>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            return data
        } catch {
            throw error
        }
    }
    
    func getRegionList() async throws -> RegionListResponse {
        do {
            let result = try await myPageProvider.request(.getUserRegion)
                .map(to: BaseResponse<RegionListResponse>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            return data
        } catch {
            throw error
        }
    }
    
    func logout() async throws -> Bool {
        do {
            let result = try await provider.request(.logout)
                .map(to: BaseResponse<BlankData>.self)
            
            return result.success
        } catch {
            throw error
        }
    }
    
    func withdraw() async throws -> Bool {
        do {
            let result = try await provider.request(.withdraw)
                .map(to: BaseResponse<BlankData>.self)
            return result.success
        } catch {
            throw error
        }
    }
}

final class MockAuthService: AuthProtocol {
    func login(platform: String, token: String, code: String?) async throws -> Bool {
        return false
    }
    
    func signup(
        platform: String,
        userName: String,
        birth: String?,
        regionId: Int?,
        introduction: String?,
        token: String,
        code: String?
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

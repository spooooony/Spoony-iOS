//
//  AuthService.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/22/25.
//

import Foundation

import Mixpanel

protocol AuthServiceProtocol {
    func login(platform: String, token: String, code: String?) async throws -> Bool
    func signup(info: SignupRequestDTO, token: String) async throws -> SignupResponseDTO
    func nicknameDuplicateCheck(userName: String) async throws -> Bool
    func getRegionList() async throws -> RegionListResponse
    func logout() async throws -> Bool
    func withdraw() async throws -> Bool
}

final class AuthService: AuthServiceProtocol {
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
    
    func signup(info: SignupRequestDTO, token: String) async throws -> SignupResponseDTO {
        do {
            let result = try await provider.request(.signup(info, token: token))
                .map(to: BaseResponse<SignupResponseDTO>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }

            return data
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

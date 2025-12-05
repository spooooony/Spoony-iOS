//
//  BlockService.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 5/26/25.
//

import Foundation

protocol BlockServiceProtocol {
    func blockUser(userId: Int) async throws
    func unblockUser(userId: Int) async throws
    func getBlockedUsers() async throws -> [BlockedUserModel]
}

final class DefaultBlockService: BlockServiceProtocol {
    private let provider = Providers.myPageProvider
    
    func blockUser(userId: Int) async throws {
        do {
            let request = TargetUserRequest(targetUserId: userId)
            let result = try await self.provider.request(.blockUser(request: request))
                .map(to: BaseResponse<BlankData>.self)
            
            if result.success {
                return
            } else {
                throw SNError.etc
            }
        } catch {
            throw error
        }
    }
    
    func unblockUser(userId: Int) async throws {
        do {
            let request = TargetUserRequest(targetUserId: userId)
            let result = try await provider.request(.unblockUser(request: request))
                .map(to: BaseResponse<BlankData>.self)
            
            if result.success {
                return
            } else {
                throw SNError.etc
            }
        } catch {
            throw error
        }
    }
    
    func getBlockedUsers() async throws -> [BlockedUserModel] {
        do {
            let result = try await provider.request(.getBlockedUsers)
                .map(to: BaseResponse<BlockedUsersResponse>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            return data.users
        } catch {
            throw error
        }
    }
}

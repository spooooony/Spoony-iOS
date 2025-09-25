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
        try await withCheckedThrowingContinuation { continuation in
            let request = TargetUserRequest(targetUserId: userId)
            provider.request(.blockUser(request: request)) { result in
                switch result {
                case .success(let response):
                    do {
                        let dto = try response.map(BaseResponse<BlankData>.self)
                        if dto.success {
                            continuation.resume()
                        } else {
                            continuation.resume(throwing: SNError.etc)
                        }
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func unblockUser(userId: Int) async throws {
        try await withCheckedThrowingContinuation { continuation in
            let request = TargetUserRequest(targetUserId: userId)
            provider.request(.unblockUser(request: request)) { result in
                switch result {
                case .success(let response):
                    do {
                        let dto = try response.map(BaseResponse<BlankData>.self)
                        if dto.success {
                            continuation.resume()
                        } else {
                            continuation.resume(throwing: SNError.etc)
                        }
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getBlockedUsers() async throws -> [BlockedUserModel] {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(.getBlockedUsers) { result in
                switch result {
                case .success(let response):
                    do {
                        let dto = try response.map(BaseResponse<BlockedUsersResponse>.self)
                        guard let data = dto.data else {
                            continuation.resume(throwing: SNError.noData)
                            return
                        }
                        continuation.resume(returning: data.users)
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

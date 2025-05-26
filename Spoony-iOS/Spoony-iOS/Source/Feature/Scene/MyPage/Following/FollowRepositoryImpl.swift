//
//  FollowRepositoryImpl.swift
//  Spoony-iOS
//
//  Created by 이명진 on 5/6/25.
//

import Foundation
import Moya

protocol FollowRepositoryInterface {
    func follow(userId: Int) async throws
    func unfollow(userId: Int) async throws
    
    func fetchMyFollowings() async throws -> FollowListDTO
    func fetchFollowings(userId: Int) async throws -> FollowListDTO
    
    func fetchMyFollowers() async throws -> FollowListDTO
    func fetchFollowers(userId: Int) async throws -> FollowListDTO
}

final class FollowRepositoryImpl: FollowRepositoryInterface {
    
    private let provider = Providers.followProvider

    func follow(userId: Int) async throws {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(.follow(targetUserId: userId)) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func unfollow(userId: Int) async throws {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(.unfollow(targetUserId: userId)) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func fetchMyFollowings() async throws -> FollowListDTO {
        return try await fetchFollowList(target: .fetchMyFollowings)
    }

    func fetchFollowings(userId: Int) async throws -> FollowListDTO {
        return try await fetchFollowList(target: .fetchFollowings(targetUserId: userId))
    }

    func fetchMyFollowers() async throws -> FollowListDTO {
        return try await fetchFollowList(target: .fetchMyFollowers)
    }

    func fetchFollowers(userId: Int) async throws -> FollowListDTO {
        return try await fetchFollowList(target: .fetchFollowers(targetUserId: userId))
    }

    // 공통 로직 재사용 함수
    private func fetchFollowList(target: FollowTargetType) async throws -> FollowListDTO {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case .success(let response):
                    do {
                        let decoded = try response.map(BaseResponse<FollowListDTO>.self)
                        guard let data = decoded.data else {
                            continuation.resume(throwing: SNError.etc)
                            return
                        }
                        continuation.resume(returning: data)
                    } catch {
                        print("🛑 [FollowRepositoryImpl] decoding failed: \(error)")
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    print("🛑 [FollowRepositoryImpl] network error: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

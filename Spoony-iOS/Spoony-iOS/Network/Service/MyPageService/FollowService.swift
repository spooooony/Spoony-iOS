//
//  FollowService.swift
//  Spoony
//
//  Created by 최주리 on 9/25/25.
//

protocol FollowServiceProtocol {
    func toggleFollow(userId: Int, isFollowing: Bool) async throws
    
    func getMyFollowers() async throws -> FollowListDTO
    func getMyFollowings() async throws -> FollowListDTO
    
    func getFollowings(userId: Int) async throws -> FollowListDTO
    func getFollowers(userId: Int) async throws -> FollowListDTO
}

final class DefaultFollowService: FollowServiceProtocol {
    
    private let provider = Providers.followProvider
    
    func toggleFollow(userId: Int, isFollowing: Bool) async throws {
        if isFollowing {
            try await unfollow(userId: userId)
        } else {
            try await follow(userId: userId)
        }
    }

    func getMyFollowings() async throws -> FollowListDTO {
        return try await fetchFollowList(target: .fetchMyFollowings)
    }

    func getFollowings(userId: Int) async throws -> FollowListDTO {
        return try await fetchFollowList(target: .fetchFollowings(targetUserId: userId))
    }

    func getMyFollowers() async throws -> FollowListDTO {
        return try await fetchFollowList(target: .fetchMyFollowers)
    }

    func getFollowers(userId: Int) async throws -> FollowListDTO {
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
    
    // MARK: private method
    
    private func follow(userId: Int) async throws {
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

    private func unfollow(userId: Int) async throws {
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

}

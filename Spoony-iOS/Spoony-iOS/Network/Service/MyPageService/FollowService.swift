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
        do {
            let result = try await provider.request(target)
                .map(to: BaseResponse<FollowListDTO>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            return data
        } catch {
            throw error
        }
    }
    
    // MARK: private method
    
    private func follow(userId: Int) async throws {
        do {
            let result = try await provider.request(.follow(targetUserId: userId))
            
            return
        } catch {
            throw error
        }
    }

    private func unfollow(userId: Int) async throws {
        do {
            let result = try await provider.request(.unfollow(targetUserId: userId))
            
            return
        } catch {
            throw error
        }
    }
}

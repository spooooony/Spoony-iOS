//
//  FollowUseCase.swift
//  Spoony-iOS
//
//  Created by 이명진 on 5/6/25.
//

import Foundation

// MARK: - UseCase Protocol

protocol FollowUseCase {
    func toggleFollow(userId: Int, isFollowing: Bool) async throws
    
    func getMyFollowers() async throws -> FollowListDTO
    func getMyFollowings() async throws -> FollowListDTO
    
    func getFollowings(userId: Int) async throws -> FollowListDTO
    func getFollowers(userId: Int) async throws -> FollowListDTO
}

final class FollowUseCaseImpl: FollowUseCase {
    
    // MARK: - Properties
    
    private let repository: FollowRepositoryInterface
    
    // MARK: - Init
    
    init(repository: FollowRepositoryInterface) {
        self.repository = repository
    }
    
}

extension FollowUseCaseImpl {
    func toggleFollow(userId: Int, isFollowing: Bool) async throws {
        if isFollowing {
            try await repository.unfollow(userId: userId)
        } else {
            try await repository.follow(userId: userId)
        }
    }
    
    func getMyFollowers() async throws -> FollowListDTO {
        return try await repository.fetchMyFollowers()
    }
    
    func getMyFollowings() async throws -> FollowListDTO {
        return try await repository.fetchMyFollowings()
    }
    
    func getFollowings(userId: Int) async throws -> FollowListDTO {
        return try await repository.fetchFollowings(userId: userId)
    }
    
    func getFollowers(userId: Int) async throws -> FollowListDTO {
        return try await repository.fetchFollowers(userId: userId)
    }
}

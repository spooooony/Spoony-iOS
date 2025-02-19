//
//  DetailRepository.swift
//  Spoony-iOS
//
//  Created by 이명진 on 2/7/25.
//

import Foundation

struct DefaultDetailService: DetailServiceProtocol { }

struct DefaultDetailRepository {
    private let detailService: DetailServiceProtocol
    
    public init(detailService: DetailServiceProtocol = DefaultDetailService()) {
        self.detailService = detailService
    }
}

extension DefaultDetailRepository: DetailRepositoryInterface {
    public func fetchReviewDetail(userId: Int, postId: Int) async throws -> ReviewDetailResponseDTO {
        return try await detailService.getReviewDetail(userId: userId, postId: postId)
    }
    
    public func scrapReview(userId: Int, postId: Int) async throws {
        try await detailService.scrapReview(userId: userId, postId: postId)
    }
    
    public func unScrapReview(userId: Int, postId: Int) async throws {
        try await detailService.unScrapReview(userId: userId, postId: postId)
    }
    
    public func scoopReview(userId: Int, postId: Int) async throws -> Bool {
        return try await detailService.scoopReview(userId: userId, postId: postId)
    }
    
    public func fetchUserInfo(userId: Int) async throws -> UserInfoResponseDTO {
        return try await detailService.getUserInfo(userId: userId)
    }
}

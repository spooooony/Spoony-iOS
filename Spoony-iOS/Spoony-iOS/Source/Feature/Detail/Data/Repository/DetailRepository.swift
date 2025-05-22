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
    
    public func fetchReviewDetail(postId: Int) async throws -> ReviewDetailResponseDTO {
        return try await detailService.getReviewDetail(postId: postId)
    }
    
    public func scrapReview(postId: Int) async throws {
        try await detailService.scrapReview(postId: postId)
    }
    
    public func unScrapReview(postId: Int) async throws {
        try await detailService.unScrapReview(postId: postId)
    }
    
    public func scoopReview(postId: Int) async throws -> Bool {
        return try await detailService.scoopReview(postId: postId)
    }
    
    func getMyUserInfo() async throws -> UserInfoResponseDTO {
        return try await detailService.getMyUserInfo()
    }
    
    func getOtherUserInfo(userId: Int) async throws -> UserInfoResponseDTO {
        return try await detailService.getOtherUserInfo(userId: userId)
    }
}

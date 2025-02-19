//
//  DetailRepositoryInterface.swift
//  Spoony-iOS
//
//  Created by 이명진 on 2/7/25.
//

protocol DetailRepositoryInterface {
    func fetchReviewDetail(userId: Int, postId: Int) async throws -> ReviewDetailResponseDTO
    func scrapReview(userId: Int, postId: Int) async throws
    func unScrapReview(userId: Int, postId: Int) async throws
    func scoopReview(userId: Int, postId: Int) async throws -> Bool
    func fetchUserInfo(userId: Int) async throws -> UserInfoResponseDTO
}

//
//  DetailRepositoryInterface.swift
//  Spoony-iOS
//
//  Created by 이명진 on 2/7/25.
//

protocol DetailRepositoryInterface {
    func fetchReviewDetail(postId: Int) async throws -> ReviewDetailResponseDTO
    func scrapReview(postId: Int) async throws
    func unScrapReview(postId: Int) async throws
    func scoopReview(postId: Int) async throws -> Bool
    func getMyUserInfo() async throws -> UserInfoResponseDTO
    func getOtherUserInfo(userId: Int) async throws -> UserInfoResponseDTO
    func deleteReview(postId: Int) async throws
}

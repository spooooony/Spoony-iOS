//
//  PostRepositoryInterface.swift
//  Spoony-iOS
//
//  Created by 이명진 on 2/7/25.
//

protocol PostRepositoryInterface {
    func getPost(postId: Int) async throws -> PostResponseDTO
    func scrapPost(postId: Int) async throws
    func unScrapPost(postId: Int) async throws
    func scoopPost(postId: Int) async throws -> Bool
    func getMyUserInfo() async throws -> UserInfoResponseDTO
    func getOtherUserInfo(userId: Int) async throws -> UserInfoResponseDTO
    func deletePost(postId: Int) async throws
}

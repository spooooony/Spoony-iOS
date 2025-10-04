//
//  PostRepository.swift
//  Spoony-iOS
//
//  Created by 이명진 on 2/7/25.
//

import Foundation

protocol PostServiceProtocol {
    func getPost(postId: Int) async throws -> PostResponseDTO
    func scrapPost(postId: Int) async throws
    func unScrapPost(postId: Int) async throws
    func scoopPost(postId: Int) async throws -> Bool
    func getMyUserInfo() async throws -> UserInfoResponseDTO
    func getOtherUserInfo(userId: Int) async throws -> UserInfoResponseDTO
    func deletePost(postId: Int) async throws
}

struct DefaultPostService: PostServiceProtocol {
    let provider = Providers.postProvider
}

extension DefaultPostService {
    public func getPost(postId: Int) async throws -> PostResponseDTO {
        do {
            let result = try await self.provider.request(.getPost(postId: postId))
                .map(to: BaseResponse<PostResponseDTO>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            return data
        } catch {
            throw error
        }
    }
    
    public func scrapPost(postId: Int) async throws {
        try await requestPostAction(targetType: .scrapPost(postId: postId))
    }
    
    public func unScrapPost(postId: Int) async throws {
        try await requestPostAction(targetType: .unScrapPost(postId: postId))
    }
    
    public func scoopPost(postId: Int) async throws -> Bool {
        do {
            let result = try await provider.request(.scoopPost(postId: postId))
                .map(to: BaseResponse<BlankData>.self)
            
            return true
        } catch {
            throw error
        }
    }
    
    func getMyUserInfo() async throws -> UserInfoResponseDTO {
        return try await requestUserInfo(targetType: .getMyUserInfo)
    }
    
    func getOtherUserInfo(userId: Int) async throws -> UserInfoResponseDTO {
        return try await requestUserInfo(targetType: .getOtherUserInfo(userId: userId))
    }
    
    func deletePost(postId: Int) async throws {
        do {
            let result = try await provider.request(.deletePost(postId: postId))
                .map(to: BaseResponse<BlankData>.self)
            
            return
        } catch {
            throw error
        }
    }
    
    // MARK: - 공통 로직
    
    // 공용 로직들을 여기에 추가
    private func requestUserInfo(targetType: PostTargetType) async throws -> UserInfoResponseDTO {
        do {
            let result = try await provider.request(targetType)
                .map(to: BaseResponse<UserInfoResponseDTO>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            return data
        } catch {
            throw error
        }
    }
    
    private func requestPostAction(targetType: PostTargetType) async throws {
        do {
            let result = try await provider.request(targetType)
                .map(to: BaseResponse<BlankData>.self)
            
            return
        } catch {
            throw error
        }
    }
}

//
//  MyPageService.swift
//  Spoony-iOS
//
//  Created by 최안용 on 5/3/25.
//

import Foundation
import Moya

protocol MypageServiceProtocol {
    func getProfileInfo() async throws -> UserProfileResponse
    func getUserInfo() async throws -> UserInfoResponse
    func nicknameDuplicationCheck(nickname: String) async throws -> Bool
    func getProfileImages() async throws -> ProfileImageResponse
    func getUserReviews() async throws -> [FeedEntity]
    func getBlockedUsers() async throws -> BlockedUsersResponse
    func unblockUser(userId: Int) async throws -> Bool
    func deleteReview(postId: Int) async throws -> Bool
    func editProfileInfo(request: EditProfileRequest) async throws -> Bool
    func getOtherUserInfo(userId: Int) async throws -> UserInfoResponse
    func getOtherUserReviews(userId: Int) async throws -> [FeedEntity]
    func getOtherUserReviews(userId: Int, isLocalReview: Bool) async throws -> [FeedEntity]
}

final class MyPageService: MypageServiceProtocol {
    private let provider = Providers.myPageProvider
    
    func getUserInfo() async throws -> UserInfoResponse {
        do {
            let result = try await provider.request(.getUserInfo)
                .map(to: BaseResponse<UserInfoResponse>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            return data
        } catch {
            throw error
        }
    }
    
    func getProfileInfo() async throws -> UserProfileResponse {
        do {
            let result = try await provider.request(.getProfileInfo)
                .map(to: BaseResponse<UserProfileResponse>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            return data
        } catch {
            throw error
        }
    }
    
    func nicknameDuplicationCheck(nickname: String) async throws -> Bool {
        do {
            let result = try await provider.request(.nicknameDuplicateCheck(query: nickname))
                .map(to: BaseResponse<Bool>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            return data
        } catch {
            throw error
        }
    }
    
    func getProfileImages() async throws -> ProfileImageResponse {
        do {
            let result = try await provider.request(.getProfileImages)
                .map(to: BaseResponse<ProfileImageResponse>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            return data
        } catch {
            throw error
        }
    }
    
    func getUserReviews() async throws -> [FeedEntity] {
        do {
            let result = try await provider.request(.getUserReviews)
                .map(to: BaseResponse<FeedListResponse>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            return data.toEntity()
        } catch {
            throw error
        }
    }
    
    func getBlockedUsers() async throws -> BlockedUsersResponse {
        do {
            let result = try await provider.request(.getBlockedUsers)
                .map(to: BaseResponse<BlockedUsersResponse>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            return data
        } catch {
            throw error
        }
    }
    
    func unblockUser(userId: Int) async throws -> Bool {
        do {
            let request = TargetUserRequest(targetUserId: userId)
            let result = try await Providers.myPageProvider.request(.unblockUser(request: request))
                .map(to: BaseResponse<BlankData>.self)
            
            return result.success
        } catch {
            throw error
        }
    }
    
    func deleteReview(postId: Int) async throws -> Bool {
        do {
            let result = try await provider.request(.deleteReview(postId: postId))
                .map(to: BaseResponse<BlankData>.self)
            
            return result.success
        } catch {
            throw error
        }
    }
    
    func editProfileInfo(request: EditProfileRequest) async throws -> Bool {
        do {
            let result = try await provider.request(.editProfileInfo(request: request))
                .map(to: BaseResponse<BlankData>.self)
            
            return result.success
        } catch {
            throw error
        }
    }
    
    func getOtherUserInfo(userId: Int) async throws -> UserInfoResponse {
        do {
            let result = try await provider.request(.getOtherInfo(userId: userId))
                .map(to: BaseResponse<UserInfoResponse>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            return data
        } catch {
            throw error
        }
    }
    
    func getOtherUserReviews(userId: Int) async throws -> [FeedEntity] {
        return try await getOtherUserReviews(userId: userId, isLocalReview: false)
    }
    
    func getOtherUserReviews(userId: Int, isLocalReview: Bool) async throws -> [FeedEntity] {
        do {
            let result = try await provider.request(.getOtherReviews(userId: userId, isLocalReview: isLocalReview))
                .map(to: BaseResponse<FeedListResponse>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            return data.toEntity()
        } catch {
            throw error
        }
    }
}

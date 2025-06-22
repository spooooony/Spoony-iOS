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
    func getOtherUserReviews(userId: Int, isLocalReview: Bool) async throws -> [FeedEntity] // 새로운 메서드
}

final class MyPageService: MypageServiceProtocol {
    private let provider = Providers.myPageProvider
    
    func getUserInfo() async throws -> UserInfoResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.getUserInfo) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<UserInfoResponse>.self)
                        guard let data = responseDto.data else {
                            continuation.resume(throwing: SNError.decodeError)
                            return
                        }
                        
                        continuation.resume(returning: data)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getProfileInfo() async throws -> UserProfileResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.getProfileInfo) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<UserProfileResponse>.self)
                        guard let data = responseDto.data else {
                            continuation.resume(throwing: SNError.decodeError)
                            return
                        }
                        
                        continuation.resume(returning: data)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func nicknameDuplicationCheck(nickname: String) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.nicknameDuplicateCheck(query: nickname)) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<Bool>.self)
                        guard let data = responseDto.data else {
                            continuation.resume(throwing: SNError.decodeError)
                            return
                        }
                        
                        continuation.resume(returning: data)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getProfileImages() async throws -> ProfileImageResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.getProfileImages) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<ProfileImageResponse>.self)
                        guard let data = responseDto.data else {
                            continuation.resume(throwing: SNError.decodeError)
                            return
                        }
                        
                        continuation.resume(returning: data)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getUserReviews() async throws -> [FeedEntity] {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.getUserReviews) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<FeedListResponse>.self)
                        guard let data = responseDto.data else {
                            continuation.resume(throwing: SNError.decodeError)
                            return
                        }
                        
                        let feedEntities = data.toEntity()
                        continuation.resume(returning: feedEntities)
                    } catch {
                        print("Review decoding error: \(error)")
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    print("Review API error: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getBlockedUsers() async throws -> BlockedUsersResponse {
        return try await withCheckedThrowingContinuation { continuation in
            Providers.myPageProvider.request(.getBlockedUsers) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<BlockedUsersResponse>.self)
                        guard let data = responseDto.data else {
                            continuation.resume(throwing: SNError.decodeError)
                            return
                        }
                        
                        continuation.resume(returning: data)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func unblockUser(userId: Int) async throws -> Bool {
        let request = TargetUserRequest(targetUserId: userId)
        
        return try await withCheckedThrowingContinuation { continuation in
            Providers.myPageProvider.request(.unblockUser(request: request)) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<BlankData>.self)
                        continuation.resume(returning: responseDto.success)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func deleteReview(postId: Int) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.deleteReview(postId: postId)) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<BlankData>.self)
                        continuation.resume(returning: responseDto.success)
                    } catch {
                        print("Review deletion error: \(error)")
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    print("Review deletion API error: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func editProfileInfo(request: EditProfileRequest) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.editProfileInfo(request: request)) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<BlankData>.self)
                        continuation.resume(returning: responseDto.success)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getOtherUserInfo(userId: Int) async throws -> UserInfoResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.getOtherInfo(userId: userId)) { result in
                switch result {
                case .success(let response):
                    do {
                        let dto = try response.map(BaseResponse<UserInfoResponse>.self)
                        guard let data = dto.data else {
                            continuation.resume(throwing: SNError.noData)
                            return
                        }
                        continuation.resume(returning: data)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getOtherUserReviews(userId: Int) async throws -> [FeedEntity] {
        return try await getOtherUserReviews(userId: userId, isLocalReview: false)
    }
    
    func getOtherUserReviews(userId: Int, isLocalReview: Bool) async throws -> [FeedEntity] {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.getOtherReviews(userId: userId, isLocalReview: isLocalReview)) { result in
                switch result {
                case .success(let response):
                    do {
                        let dto = try response.map(BaseResponse<FeedListResponse>.self)
                        guard let data = dto.data else {
                            continuation.resume(throwing: SNError.noData)
                            return
                        }
                        continuation.resume(returning: data.toEntity())
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

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
}

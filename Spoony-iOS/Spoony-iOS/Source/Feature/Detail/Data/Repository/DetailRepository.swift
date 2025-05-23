//
//  DetailRepository.swift
//  Spoony-iOS
//
//  Created by 이명진 on 2/7/25.
//

import Foundation

struct DefaultDetailRepository: DetailRepositoryInterface { }

extension DefaultDetailRepository {
    
    public func fetchReviewDetail(postId: Int) async throws -> ReviewDetailResponseDTO {
        return try await withCheckedThrowingContinuation { continuation in
            Providers.detailProvider.request(.getDetailReview(postId: postId)) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<ReviewDetailResponseDTO>.self)
                        if let data = responseDto.data {
                            continuation.resume(returning: data)
                        } else {
                            continuation.resume(throwing: SNError.decodeError)
                        }
                    } catch {
                        continuation.resume(throwing: SNError.etc)
                    }
                case .failure:
                    continuation.resume(throwing: SNError.networkFail)
                }
            }
        }
    }
    
    public func scrapReview(postId: Int) async throws {
        try await requestReviewAction(targetType: .scrapReview(postId: postId))
    }
    
    public func unScrapReview(postId: Int) async throws {
        try await requestReviewAction(targetType: .unScrapReview(postId: postId))
    }
    
    public func scoopReview(postId: Int) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            Providers.detailProvider.request(.scoopReview(postId: postId)) { result in
                switch result {
                case .success(let response):
                    do {
                        _ = try response.map(BaseResponse<BlankData>.self)
                        continuation.resume(returning: true)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getMyUserInfo() async throws -> UserInfoResponseDTO {
        return try await requestUserInfo(targetType: .getMyUserInfo)
    }
    
    func getOtherUserInfo(userId: Int) async throws -> UserInfoResponseDTO {
        return try await requestUserInfo(targetType: .getOtherUserInfo(userId: userId))
    }
    
    // DetailService의 공용 로직들을 여기에 추가
    private func requestUserInfo(targetType: DetailTargetType) async throws -> UserInfoResponseDTO {
        return try await withCheckedThrowingContinuation { continuation in
            Providers.detailProvider.request(targetType) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<UserInfoResponseDTO>.self)
                        if let data = responseDto.data {
                            continuation.resume(returning: data)
                        } else {
                            continuation.resume(throwing: SNError.decodeError)
                        }
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: PostError.userError)
                }
            }
        }
    }
    
    private func requestReviewAction(targetType: DetailTargetType) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            Providers.detailProvider.request(targetType) { result in
                switch result {
                case .success(let response):
                    do {
                        _ = try response.map(BaseResponse<BlankData>.self)
                        continuation.resume()
                    } catch {
                        continuation.resume(throwing: SNError.decodeError)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

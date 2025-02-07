//
//  DetailService.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/23/25.
//

protocol DetailServiceProtocol {
    func getReviewDetail(userId: Int, postId: Int) async throws -> ReviewDetailResponseDTO
    func scrapReview(userId: Int, postId: Int) async throws
    func unScrapReview(userId: Int, postId: Int) async throws
    func scoopReview(userId: Int, postId: Int) async throws -> Bool
    func getUserInfo(userId: Int) async throws -> UserInfoResponseDTO
}

extension DetailServiceProtocol {
    func getReviewDetail(userId: Int, postId: Int) async throws -> ReviewDetailResponseDTO {
        return try await withCheckedThrowingContinuation { continuation in
            Providers.detailProvider.request(.getDetailReview(userId: userId, postId: postId)) { result in
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
    
    func scrapReview(userId: Int, postId: Int) async throws {
        try await requestReviewAction(targetType: .scrapReview(userId: userId, postId: postId))
    }
    
    func unScrapReview(userId: Int, postId: Int) async throws {
        try await requestReviewAction(targetType: .unScrapReview(userId: userId, postId: postId))
    }
    
    func scoopReview(userId: Int, postId: Int) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            Providers.detailProvider.request(.scoopReview(userId: userId, postId: postId)) { result in
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
    
    func getUserInfo(userId: Int) async throws -> UserInfoResponseDTO {
        return try await withCheckedThrowingContinuation { continuation in
            Providers.detailProvider.request(.getUserInfo(userId: userId)) { result in
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
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // 스크랩 공용 Logic
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

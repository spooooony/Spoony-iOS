//
//  DetailService.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/23/25.
//

protocol DetailServiceProtocol {
    func getReviewDetail(postId: Int) async throws -> ReviewDetailResponseDTO
    func scrapReview(postId: Int) async throws
    func unScrapReview(postId: Int) async throws
    func scoopReview(postId: Int) async throws -> Bool
    func getUserInfo() async throws -> UserInfoResponseDTO
}

extension DetailServiceProtocol {
    func getReviewDetail(postId: Int) async throws -> ReviewDetailResponseDTO {
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
    
    func scrapReview(postId: Int) async throws {
        try await requestReviewAction(targetType: .scrapReview(postId: postId))
    }
    
    func unScrapReview(postId: Int) async throws {
        try await requestReviewAction(targetType: .unScrapReview(postId: postId))
    }
    
    func scoopReview(postId: Int) async throws -> Bool {
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
    
    func getUserInfo() async throws -> UserInfoResponseDTO {
        return try await withCheckedThrowingContinuation { continuation in
            Providers.detailProvider.request(.getUserInfo) { result in
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

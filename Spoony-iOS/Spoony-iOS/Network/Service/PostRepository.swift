//
//  PostRepository.swift
//  Spoony-iOS
//
//  Created by 이명진 on 2/7/25.
//

import Foundation

protocol PostService {
    func getPost(postId: Int) async throws -> PostResponseDTO
    func scrapPost(postId: Int) async throws
    func unScrapPost(postId: Int) async throws
    func scoopPost(postId: Int) async throws -> Bool
    func getMyUserInfo() async throws -> UserInfoResponseDTO
    func getOtherUserInfo(userId: Int) async throws -> UserInfoResponseDTO
    func deletePost(postId: Int) async throws
}

struct DefaultPostService: PostService {
    let provider = Providers.postProvider
}

extension DefaultPostService {
    
    public func getPost(postId: Int) async throws -> PostResponseDTO {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.getPost(postId: postId)) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<PostResponseDTO>.self)
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
    
    public func scrapPost(postId: Int) async throws {
        try await requestPostAction(targetType: .scrapPost(postId: postId))
    }
    
    public func unScrapPost(postId: Int) async throws {
        try await requestPostAction(targetType: .unScrapPost(postId: postId))
    }
    
    public func scoopPost(postId: Int) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.scoopPost(postId: postId)) { result in
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
    
    func deletePost(postId: Int) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.deletePost(postId: postId)) { result in
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
    
    // MARK: - 공통 로직
    
    // 공용 로직들을 여기에 추가
    private func requestUserInfo(targetType: PostTargetType) async throws -> UserInfoResponseDTO {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(targetType) { result in
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
                case .failure:
                    continuation.resume(throwing: PostError.userError)
                }
            }
        }
    }
    
    private func requestPostAction(targetType: PostTargetType) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(targetType) { result in
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

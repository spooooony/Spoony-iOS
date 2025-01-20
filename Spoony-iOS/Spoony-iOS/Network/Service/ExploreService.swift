//
//  ExploreService.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/20/25.
//

import Foundation

import Moya

protocol ExploreProtocol {
    func getUserFeed(userId: Int, location: String, sort: FilterType) async throws -> [FeedResponse]
}

final class DefaultExploreService: ExploreProtocol {
    let provider = Providers.explorProvider
    
    func getUserFeed(userId: Int, location: String, sort: FilterType) async throws -> [FeedResponse] {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(
                .getUserFeeds(
                    userId: userId,
                    location: location,
                    sort: sort
                )
            ) { result in
                switch result {
                case .success(let response):
                    do {
                        guard let data = try JSONDecoder()
                            .decode(BaseResponse<[FeedResponse]>.self, from: response.data)
                            .data else { return }
                        
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
    
}

final class MockExploreService: ExploreProtocol {
    func getUserFeed(userId: Int, location: String, sort: FilterType) async throws -> [FeedResponse] {
        return [FeedResponse.sample, FeedResponse.sample, FeedResponse.sample]
    }
}

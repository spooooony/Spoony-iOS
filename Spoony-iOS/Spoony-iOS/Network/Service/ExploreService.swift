//
//  ExploreService.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/20/25.
//

import Foundation

import Moya

protocol ExploreProtocol {
    func getUserFeed(
        userId: Int,
        categoryId: Int,
        location: String,
        sort: FilterType
    ) async throws -> FeedListResponse
}

final class DefaultExploreService: ExploreProtocol {
    let provider = Providers.explorProvider
    
    func getUserFeed(
        userId: Int,
        categoryId: Int,
        location: String,
        sort: FilterType
    ) async throws -> FeedListResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(
                .getUserFeeds(
                    userId: userId,
                    categoryId: categoryId,
                    location: location,
                    sort: sort
                )
            ) { result in
                switch result {
                case .success(let response):
                    do {
                        guard let result = try response.map(BaseResponse<FeedListResponse>.self).data
                        else { return }
                        
                        continuation.resume(returning: result)
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
    func getUserFeed(
        userId: Int,
        categoryId: Int,
        location: String,
        sort: FilterType
    ) async throws -> FeedListResponse {
        return .init(feedResponseList: [
            FeedResponse.sample,
            FeedResponse.sample,
            FeedResponse.sample
        ])
    }
}

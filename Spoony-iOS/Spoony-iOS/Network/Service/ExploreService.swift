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
    
    func getCategoryList() async throws -> SearchCategoryListResponse
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
                        let responseDto = try response.map(BaseResponse<FeedListResponse>.self)
                        guard let data = responseDto.data else { return }
                        
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
    
    func getCategoryList() async throws -> SearchCategoryListResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.getCategories) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<SearchCategoryListResponse>.self)
                        guard let data = responseDto.data else { return }
                        
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
    func getUserFeed(
        userId: Int,
        categoryId: Int,
        location: String,
        sort: FilterType
    ) async throws -> FeedListResponse {
        return .init(feedResponseList: [
            
        ])
    }
    
    func getCategoryList() async throws -> SearchCategoryListResponse {
        return .init(
            categoryMonoList: [
                .init(
                    categoryId: 1,
                    categoryName: "로컬 수저",
                    iconUrlNotSelected: "",
                    iconUrlSelected: ""
                ),
                .init(
                    categoryId: 2,
                    categoryName: "한식",
                    iconUrlNotSelected: "",
                    iconUrlSelected: ""
                ),
                .init(
                    categoryId: 3,
                    categoryName: "일식",
                    iconUrlNotSelected: "",
                    iconUrlSelected: ""
                ),
                .init(
                    categoryId: 4,
                    categoryName: "중식",
                    iconUrlNotSelected: "",
                    iconUrlSelected: ""
                ),
                .init(
                    categoryId: 5,
                    categoryName: "양식",
                    iconUrlNotSelected: "",
                    iconUrlSelected: ""
                ),
                .init(
                    categoryId: 6,
                    categoryName: "퓨전/세계요리",
                    iconUrlNotSelected: "",
                    iconUrlSelected: ""
                ),
                .init(
                    categoryId: 7,
                    categoryName: "카페",
                    iconUrlNotSelected: "",
                    iconUrlSelected: ""
                ),
                .init(
                    categoryId: 8,
                    categoryName: "주류",
                    iconUrlNotSelected: "",
                    iconUrlSelected: ""
                )
            ]
        )
    }
}

//
//  ExploreService.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/20/25.
//

import Foundation

import Moya

protocol ExploreProtocol {
    func getCategoryList() async throws -> SearchCategoryListResponse
    
    func getFeedList() async throws -> FeedListResponse
    func getFollowingFeedList() async throws -> FeedListResponse
}

final class DefaultExploreService: ExploreProtocol {
    let provider = Providers.explorProvider
    
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
    
    func getFeedList() async throws -> FeedListResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.getFeedList) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<FeedListResponse>.self)
                        guard let data = responseDto.data
                        else { throw SNError.decodeError }
                        
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
    // todo
    func getFollowingFeedList() async throws -> FeedListResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.getFollowingFeedList) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<FeedListResponse>.self)
                        guard let data = responseDto.data
                        else { throw SNError.decodeError }
                        
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
    
    func getFeedList() async throws -> FeedListResponse {
        return .init(
            feedResponseList: [
//                .init(
//                    userId: 1,
//                    userName: "지훈",
//                    createdAt: "2025-05-04T12:11:17.333Z",
//                    userRegion: "강동구",
//                    postId: 1,
//                    description: "어쩌구저쩌구",
//                    categoryColorResponse: .init(
//                        categoryName: "한식",
//                        iconUrl: "",
//                        iconTextColor: "",
//                        iconBackgroundColor: ""
//                    ),
//                    zzimCount: 2,
//                    photoUrlList: []
//                )
            ]
        )
    }
    
    func getFollowingFeedList() async throws -> FeedListResponse {
        return .init(feedResponseList: [
//            .init(
//                userId: 1,
//                userName: "안용",
//                createdAt: "2025-05-03T12:11:17.333Z",
//                userRegion: "강서구",
//                postId: 1,
//                description: "어쩌구저쩌구",
//                categoryColorResponse: .init(
//                    categoryName: "양식",
//                    iconUrl: "",
//                    iconTextColor: "",
//                    iconBackgroundColor: ""
//                ),
//                zzimCount: 3,
//                photoUrlList: []
//            )
        ])
    }
}

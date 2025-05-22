//
//  ExploreService.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/20/25.
//

import Foundation

import Moya

protocol ExploreProtocol {
    func getFilteredFeedList(
        isLocal: Bool,
        category: [Int],
        region: [Int],
        age: [String],
        sort: SortType,
        cursor: Int
    ) async throws -> FilteredFeedResponse
    func getFollowingFeedList() async throws -> FeedListResponse
    
    // 추후 카테고리 리스트 받아오는 코드 자체를 각 서비스에서 분리해서 새로운 서비스 파일을 만드는 방향
    func getRegionList() async throws -> RegionListResponse
    func getCategoryList() async throws -> CategoryListResponse
    
    func searchUser(keyword: String) async throws -> UserSimpleListResponse
    func searchReview(keyword: String) async throws -> ReviewSearchListResponse
}

final class DefaultExploreService: ExploreProtocol {
    let provider = Providers.explorProvider
    let registerProvider = Providers.registerProvider
    let mypageProvider = Providers.myPageProvider
    
    func getFilteredFeedList(
        isLocal: Bool,
        category: [Int],
        region: [Int],
        age: [String],
        sort: SortType,
        cursor: Int
    ) async throws -> FilteredFeedResponse {
        return try await withCheckedThrowingContinuation { continuation in
            let request: FilteredFeedRequest = .init(
                isLocal: isLocal,
                categoryIds: category,
                regionIds: region,
                ageGroups: age,
                sortBy: sort.rawValue,
                cursor: cursor,
                size: 5
            )
            provider.request(.getFilteredFeedList(request)) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<FilteredFeedResponse>.self)
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
    
    func getCategoryList() async throws -> CategoryListResponse {
        return try await withCheckedThrowingContinuation { continuation in
            registerProvider.request(.getRegisterCategories) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<CategoryListResponse>.self)
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
    
    func getRegionList() async throws -> RegionListResponse {
        return try await withCheckedThrowingContinuation { continuation in
            mypageProvider.request(.getUserRegion) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<RegionListResponse>.self)
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
    
    func searchUser(keyword: String) async throws -> UserSimpleListResponse {
        return try await withCheckedThrowingContinuation { continuation in
            mypageProvider.request(.searchUser(query: keyword)) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<UserSimpleListResponse>.self)
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
    
    func searchReview(keyword: String) async throws -> ReviewSearchListResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.searchPost(query: keyword)) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<ReviewSearchListResponse>.self)
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
    func getFilteredFeedList(
        isLocal: Bool,
        category: [Int],
        region: [Int],
        age: [String],
        sort: SortType,
        cursor: Int
    ) async throws -> FilteredFeedResponse {
        return .init(
            filteredFeedResponseDTOList: [],
            nextCursor: cursor
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
    
    func getCategoryList() async throws -> CategoryListResponse {
        return .init(
            categoryMonoList: [
                .init(
                    categoryId: 0,
                    categoryName: "",
                    iconUrlNotSelected: "",
                    iconUrlSelected: ""
                )
            ]
        )
    }
    
    func getRegionList() async throws -> RegionListResponse {
        return .init(regionList: [])
    }
    
    func searchUser(keyword: String) async throws -> UserSimpleListResponse {
        return .init(userSimpleResponseDTO: [])
    }
    
    func searchReview(keyword: String) async throws -> ReviewSearchListResponse {
        return .init(postSearchResultList: [])
    }
}

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
        cursor: String?
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
        cursor: String?
    ) async throws -> FilteredFeedResponse {
        do {
            let request: FilteredFeedRequest = .init(
                isLocal: isLocal,
                categoryIds: category,
                regionIds: region,
                ageGroups: age,
                sortBy: sort.rawValue,
                cursor: cursor
            )
            
            let result = try await provider.request(.getFilteredFeedList(request))
                .map(to: BaseResponse<FilteredFeedResponse>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            return data
        } catch {
            throw error
        }
    }

    func getFollowingFeedList() async throws -> FeedListResponse {
        do {
            let result = try await provider.request(.getFollowingFeedList)
                .map(to: BaseResponse<FeedListResponse>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            return data
        } catch {
            throw error
        }
    }
    
    func getCategoryList() async throws -> CategoryListResponse {
        do {
            let result = try await registerProvider.request(.getRegisterCategories)
                .map(to: BaseResponse<CategoryListResponse>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            return data
        } catch {
            throw error
        }
    }
    
    func getRegionList() async throws -> RegionListResponse {
        do {
            let result = try await mypageProvider.request(.getUserRegion)
                .map(to: BaseResponse<RegionListResponse>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            return data
        } catch {
            throw error
        }
    }
    
    func searchUser(keyword: String) async throws -> UserSimpleListResponse {
        do {
            let result = try await mypageProvider.request(.searchUser(query: keyword))
                .map(to: BaseResponse<UserSimpleListResponse>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            return data
        } catch {
            throw error
        }
    }
    
    func searchReview(keyword: String) async throws -> ReviewSearchListResponse {
        do {
            let result = try await provider.request(.searchPost(query: keyword))
                .map(to: BaseResponse<ReviewSearchListResponse>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
                
            return data
        } catch {
            throw error
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
        cursor: String?
    ) async throws -> FilteredFeedResponse {
        return .init(
            filteredFeedResponseDTOList: [],
            nextCursor: ""
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

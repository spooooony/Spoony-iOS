//
//  ExploreService.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/20/25.
//

import Foundation

import Moya

protocol ExploreProtocol {
    func getFeedList() async throws -> FeedListResponse
    func getFollowingFeedList() async throws -> FeedListResponse
    
    func getRegionList() async throws -> RegionListResponse
    // TODO: 모델명 바꾸기 ..
    // register service에 존재하는 코드인데 이것만을 사용하기 위해 또 registerService를 선언하는 것이 조금 이상하게 생각되어서 중복코드를 만들어버렸습니다...
    // 추후 카테고리 리스트 받아오는 코드 자체를 각 서비스에서 분리해서 새로운 서비스 파일을 만드는 방향이 좋아보이는데 어떻게 생각하시는지 궁금하네요 !
    // 같은 맥락으로 region list 관련 api도 ....
    func getCategoryList() async throws -> RegisterCategoryResponse
}

final class DefaultExploreService: ExploreProtocol {
    let provider = Providers.explorProvider
    let registerProvider = Providers.registerProvider
    let mypageProvider = Providers.myPageProvider
    
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
    
    func getCategoryList() async throws -> RegisterCategoryResponse {
        return try await withCheckedThrowingContinuation { continuation in
            registerProvider.request(.getRegisterCategories) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<RegisterCategoryResponse>.self)
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
}

final class MockExploreService: ExploreProtocol {
    
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
    
    func getCategoryList() async throws -> RegisterCategoryResponse {
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
}

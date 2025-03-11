//
//  MockDetailViewStore.swift
//  Spoony-iOS
//
//  Created by 이명진 on 3/4/25.
//

import Foundation

struct MockDetailUseCase: DetailUseCaseProtocol {
    
    func fetchInitialDetail(postId: Int) async throws -> ReviewDetailModel {
        return MockData.reviewDetail
    }
    
    func scrapReview(postId: Int) async throws {
        print("스크랩")
    }
    
    func unScrapReview(postId: Int) async throws {
        print("스크랩 취소")
    }
    
    func scoopReview(postId: Int) async throws -> Bool {
        print("떠먹기 기능")
        return true
    }
    
    func getUserInfo() async throws -> UserInfoResponseDTO {
        return MockData.userInfo
    }
}

struct MockData {
    
    static let reviewDetailResponse: ReviewDetailResponseDTO = ReviewDetailResponseDTO(
        postId: 20,
        userId: 30,
        photoUrlList: [
            "https://spoony-storage.s3.ap-northeast-2.amazonaws.com/post/4e827dbf-a100-4dff-837e-ed4008e050421-1.jpeg",
            "https://spoony-storage.s3.ap-northeast-2.amazonaws.com/post/e159e90c-7fc4-46cc-aab5-d82410208b7a1-2.jpeg",
            "https://spoony-storage.s3.ap-northeast-2.amazonaws.com/post/e383b6fc-1d2e-4824-83ce-56e0c3620eb21-3.jpg"
        ],
        title: "테스트 제목",
        date: "2025-03-04T10:46:14",
        menuList: ["메뉴1", "메뉴2"],
        description: "테스트 설명 여기 왜 왼쪽 정렬이 안되냐 ..",
        placeName: "테스트 장소",
        placeAddress: "서울 강남구",
        latitude: 37.497946,
        longitude: 127.027632,
        zzimCount: 1,
        isZzim: true,
        isScoop: true,
        isMine: false,
        categoryColorResponse: DetailCategoryColorResponse(
            categoryId: 1,
            categoryName: "전체",
            iconUrl: nil,
            iconTextColor: nil,
            iconBackgroundColor: nil
        )
    )
    
    static let userInfo: UserInfoResponseDTO = UserInfoResponseDTO(
        userId: 30,
        platform: "APPLE",
        platformId: "test_id_30",
        userName: "이지훈",
        userImageUrl: "https://spoony-storage.s3.ap-northeast-2.amazonaws.com/profile/image_avatar_hamburger.png",
        regionName: "강북구",
        createdAt: "2025-03-01T12:34:56",
        updatedAt: "2025-03-01T12:34:56"
    )
    
    static let spoonCount: Int = 5623
    
    // 최종적으로 사용될 Mock ReviewDetailModel
    static let reviewDetail: ReviewDetailModel = ReviewDetailModel(
        reviewDetail: reviewDetailResponse,
        userInfo: userInfo,
        spoonCount: spoonCount
    )
}

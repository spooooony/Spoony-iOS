//
//  ReviewDetailModel.swift
//  Spoony-iOS
//
//  Created by 이명진 on 2/7/25.
//

import Foundation

struct ReviewDetailModel: Codable {
    let userId: Int
    let postId: Int
    let photoUrlList: [String]
    let date: String
    let menuList: [String]
    let description: String
    let placeName: String
    let placeAddress: String
    let latitude: Double
    let longitude: Double
    let zzimCount: Int
    let isZzim: Bool
    let isScoop: Bool
    let categoryColorResponse: DetailCategoryColorResponse
    let isMine: Bool
    let spoonCount: Int
    let userName: String
    let profileImageUrl: String
    let regionName: String
    let value: Double
    let cons: String
    let isFollowing: Bool
    
    public init(reviewDetail: ReviewDetailResponseDTO, userInfo: UserInfoResponseDTO, spoonCount: Int) {
        self.userId = userInfo.userId
        self.postId = reviewDetail.postId
        self.photoUrlList = reviewDetail.photoUrlList
        self.date = reviewDetail.date
        self.menuList = reviewDetail.menuList
        self.description = reviewDetail.description
        self.placeName = reviewDetail.placeName
        self.placeAddress = reviewDetail.placeAddress
        self.latitude = reviewDetail.latitude
        self.longitude = reviewDetail.longitude
        self.zzimCount = reviewDetail.zzimCount
        self.isZzim = reviewDetail.isZzim
        self.isScoop = reviewDetail.isScoop
        self.categoryColorResponse = reviewDetail.categoryColorResponse
        self.isMine = reviewDetail.isMine
        self.userName = userInfo.userName
        self.profileImageUrl = userInfo.profileImageUrl
        self.regionName = userInfo.regionName
        self.spoonCount = spoonCount
        self.value = reviewDetail.value
        self.cons = reviewDetail.cons
        self.isFollowing = userInfo.isFollowing
    }
}

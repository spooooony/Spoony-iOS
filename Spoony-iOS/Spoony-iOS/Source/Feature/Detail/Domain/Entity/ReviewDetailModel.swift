//
//  ReviewDetailModel.swift
//  Spoony-iOS
//
//  Created by 이명진 on 2/7/25.
//

import Foundation

struct ReviewDetailModel: Codable {
    let postId: Int
    let photoUrlList: [String]
    let title: String
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
    let userImageUrl: String
    let regionName: String
    
    public init(reviewDetail: ReviewDetailResponseDTO, userInfo: UserInfoResponseDTO, spoonCount: Int) {
        self.postId = reviewDetail.postId
        self.photoUrlList = reviewDetail.photoUrlList
        self.title = reviewDetail.title
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
        self.userImageUrl = userInfo.userImageUrl
        self.regionName = userInfo.regionName
        self.spoonCount = spoonCount
    }
}

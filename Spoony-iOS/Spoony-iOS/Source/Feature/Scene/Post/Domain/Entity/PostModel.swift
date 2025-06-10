//
//  PostModel.swift
//  Spoony-iOS
//
//  Created by 이명진 on 2/7/25.
//

import Foundation

struct PostModel: Codable {
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
    
    public init(postDto: PostResponseDTO, userInfo: UserInfoResponseDTO, spoonCount: Int) {
        self.userId = userInfo.userId
        self.postId = postDto.postId
        self.photoUrlList = postDto.photoUrlList
        self.date = postDto.date
        self.menuList = postDto.menuList
        self.description = postDto.description
        self.placeName = postDto.placeName
        self.placeAddress = postDto.placeAddress
        self.latitude = postDto.latitude
        self.longitude = postDto.longitude
        self.zzimCount = postDto.zzimCount
        self.isZzim = postDto.isZzim
        self.isScoop = postDto.isScoop
        self.categoryColorResponse = postDto.categoryColorResponse
        self.isMine = postDto.isMine
        self.userName = userInfo.userName
        self.profileImageUrl = userInfo.profileImageUrl
        self.regionName = userInfo.regionName ?? ""
        self.spoonCount = spoonCount
        self.value = postDto.value
        self.cons = postDto.cons ?? ""
        self.isFollowing = userInfo.isFollowing
    }
}

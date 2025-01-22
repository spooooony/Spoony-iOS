//
//  MapFocusResponse.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/22/25.
//

import Foundation

struct MapFocusResponse: Codable {
    let zzimFocusResponseList: [FocusPlaceResponse]
}

struct FocusPlaceResponse: Codable {
    let placeId: Int
    let placeName: String
    let categoryColorResponse: MapFocusCategoryColorResponse
    let authorName: String
    let authorRegionName: String
    let postId: Int
    let postTitle: String
    let zzimCount: Int
    let photoUrlList: [String]
}

struct MapFocusCategoryColorResponse: Codable {
    let categoryId: Int
    let categoryName: String
    let iconUrl: String
    let iconTextColor: String
    let iconBackgroundColor: String
}

extension FocusPlaceResponse {
    func toCardPlace() -> CardPlace {
        return CardPlace(
            name: placeName,
            visitorCount: "\(zzimCount)명",
            address: authorRegionName,
            images: photoUrlList,
            title: postTitle,
            subTitle: postTitle,
            description: categoryColorResponse.categoryName,
            categoryColor: categoryColorResponse.iconBackgroundColor,
            categoryTextColor: categoryColorResponse.iconTextColor
        )
    }
}

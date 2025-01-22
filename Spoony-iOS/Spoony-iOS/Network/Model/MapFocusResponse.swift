//
//  MapFocusResponse.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/22/25.
//

import Foundation

struct MapFocusResponse: Codable {
    let zzimFocusResponseList: [MapFocusItem]
}

struct MapFocusItem: Codable {
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
    let categoryName: String
    let iconUrl: String
    let iconTextColor: String
    let iconBackgroundColor: String
}

extension MapFocusItem {
    func toCardPlace() -> CardPlace {
        return CardPlace(
            name: placeName,
            visitorCount: "\(zzimCount)",
            address: authorRegionName,
            images: photoUrlList,
            title: postTitle,
            subTitle: categoryColorResponse.categoryName,
            description: "by \(authorName)"
        )
    }
}

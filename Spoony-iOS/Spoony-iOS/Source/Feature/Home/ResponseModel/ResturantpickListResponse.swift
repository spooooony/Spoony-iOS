//
//  ResturantpickListResponse.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/21/25.
//

import Foundation

struct ResturantpickListResponse: Codable {
    let zzimCardResponses: [PickListCardResponse]
}

struct PickListCardResponse: Codable {
    let placeId: Int
    let placeName: String
    let placeAddress: String
    let postTitle: String
    let latitude: Double
    let longitude: Double
    let categoryColorResponse: CategoryColorResponse
}

struct CategoryColorResponse: Codable {
    let categoryName: String
    let iconUrl: String
    let iconTextColor: String
    let iconBackgroundColor: String
}

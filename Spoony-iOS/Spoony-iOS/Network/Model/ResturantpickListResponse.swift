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

struct PickListCardResponse: Codable, Equatable {
    let placeId: Int
    let placeName: String
    let placeAddress: String
    let postTitle: String
    let photoUrl: String
    let latitude: Double
    let longitude: Double
    let categoryColorResponse: BottomSheetCategoryColorResponse
    
    static func == (lhs: PickListCardResponse, rhs: PickListCardResponse) -> Bool {
        return lhs.placeId == rhs.placeId 
    }
}

struct BottomSheetCategoryColorResponse: Codable, Equatable {
    let categoryId: Int
    let categoryName: String
    let iconUrl: String
    let iconTextColor: String
    let iconBackgroundColor: String
}

//
//  SearchResult.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/16/25.
//

import Foundation

struct SearchResult: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let locationId: Int
    let address: String
}

extension PickListCardResponse {
    func toSearchLocationResult() -> SearchLocationResult {
        return SearchLocationResult(
            locationId: self.placeId,
            placeId: self.placeId,
            title: self.placeName,
            address: self.placeAddress,
            postTitle: self.postTitle,
            photoUrl: self.photoUrl,
            latitude: self.latitude,
            longitude: self.longitude,
            categoryColorResponse: self.categoryColorResponse.toSearchCategoryColorResponse() 
        )
    }
}

extension BottomSheetCategoryColorResponse {
    func toSearchCategoryColorResponse() -> SearchCategoryColorResponse {
        return SearchCategoryColorResponse(
            categoryId: self.categoryId,
            categoryName: self.categoryName,
            iconUrl: self.iconUrl,
            iconTextColor: self.iconTextColor,
            iconBackgroundColor: self.iconBackgroundColor
        )
    }
}

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
    let latitude: Double?
    let longitude: Double?
}

extension PickListCardResponse {
    func toSearchLocationResult() -> SearchLocationResult {
        return SearchLocationResult(
            locationId: self.placeId,
            placeId: self.placeId,
            title: self.placeName,
            address: self.placeAddress,
            postTitle: self.postTitle,
            description: self.description,
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
            categoryName: self.categoryName ?? "",
            iconUrl: self.iconUrl ?? "",
            iconTextColor: self.iconTextColor ?? "",
            iconBackgroundColor: self.iconBackgroundColor ?? ""
        )
    }
}

extension SearchLocationResult {
    func toPickListCardResponse() -> PickListCardResponse {
        return PickListCardResponse(
            placeId: self.placeId ?? 0,
            placeName: self.title,
            placeAddress: self.address,
            postTitle: self.postTitle ?? "",
            description: self.description ?? "",
            photoUrl: self.photoUrl ?? "",
            latitude: self.latitude ?? 0.0,
            longitude: self.longitude ?? 0.0,
            categoryColorResponse: self.categoryColorResponse?.toBottomSheetCategoryColorResponse() ??
                BottomSheetCategoryColorResponse(categoryId: 0, categoryName: "", iconUrl: "", iconTextColor: "", iconBackgroundColor: "")
        )
    }
}

extension SearchCategoryColorResponse {
    func toBottomSheetCategoryColorResponse() -> BottomSheetCategoryColorResponse {
        return BottomSheetCategoryColorResponse(
            categoryId: self.categoryId,
            categoryName: self.categoryName,
            iconUrl: self.iconUrl,
            iconTextColor: self.iconTextColor,
            iconBackgroundColor: self.iconBackgroundColor
        )
    }
}

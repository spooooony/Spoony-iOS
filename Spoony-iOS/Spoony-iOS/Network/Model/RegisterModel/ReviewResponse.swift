//
//  ReviewResponse.swift
//  Spoony-iOS
//
//  Created by 최안용 on 5/5/25.
//

import Foundation

struct ReviewResponse: Codable {
    let userId: Int
    let zzimCount: Int
    let photoUrlList: [String]
    let menuList: [String]
    let description: String
    let value: Double?
    let cons: String?
    let placeName: String
    let placeAddress: String
    let categoryColorResponse: CategoryColorResponse
}

extension ReviewResponse {
    func toModel() -> ReviewInfo {
        return .init(
            userId: userId,
            savedCount: zzimCount,
            uploadImages: photoUrlList.map { .init(image: nil, imageData: nil, url: $0) },
            menuList: menuList,
            description: description,
            value: value ?? 50.0,
            cons: cons ?? "",
            placeName: placeName,
            placeAddress: placeAddress,
            selectedCategoryId: categoryColorResponse.categoryId ?? 0
        )
    }
}

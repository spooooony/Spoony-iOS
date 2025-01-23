//
//  DetailModel.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/20/25.
//

import Foundation


// MARK: - ReviewDetailModel

struct ReviewDetailModel: Codable {
    let postId: Int
    let userId: Int
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
}

// MARK: - DetailCategoryColorResponse

struct DetailCategoryColorResponse: Codable {
    let categoryName: String
    let iconUrl: String
    let iconTextColor: String
    let iconBackgroundColor: String
    let categoryId: Int // 추가된 필드
}

// MARK: - Entity

extension DetailCategoryColorResponse {
    func toEntity() -> ChipColorEntity {
        .init(
            name: self.categoryName,
            iconUrl: self.iconUrl,
            textColor: self.iconTextColor,
            backgroundColor: self.iconBackgroundColor
        )
    }
}

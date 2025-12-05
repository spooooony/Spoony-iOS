//
//  PostResponseDTO.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/20/25.
//

import Foundation

// MARK: - PostResponseDTO

struct PostResponseDTO: Codable, Equatable {
    let postId: Int
    let userId: Int
    let photoUrlList: [String]
    let date: String
    let menuList: [String]
    let description: String
    let value: Double
    let cons: String?
    let placeName: String
    let placeAddress: String
    let latitude: Double
    let longitude: Double
    let zzimCount: Int
    let isZzim: Bool
    let isScoop: Bool
    let isMine: Bool
    let categoryColorResponse: DetailCategoryColorResponse
}

// MARK: - DetailCategoryColorResponse
struct DetailCategoryColorResponse: Codable, Equatable {
    let categoryId: Int
    let categoryName: String
    let iconUrl: String?
    let iconTextColor: String?
    let iconBackgroundColor: String?
}

// MARK: - ChipColorEntity

extension DetailCategoryColorResponse {
    func toEntity() -> ChipColorEntity {
        .init(
            name: self.categoryName,
            iconUrl: self.iconUrl ?? "",
            textColor: self.iconTextColor ?? "",
            backgroundColor: self.iconBackgroundColor ?? ""
        )
    }
}

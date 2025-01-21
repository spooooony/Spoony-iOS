//
//  DetailModel.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/20/25.
//

import Foundation

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
    let zzinCount: Int
    let isZzim: Bool
    let isScoop: Bool
    let categoryColorResponse: CategoryColorResponse
}

struct CategoryColorResponse: Codable {
    let categoryName: String
    let colorIconUrl: String
    let iconBackgroundColor: String
}

//
//  SearchLocationResponse.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/30/25.
//

import Foundation

struct SearchLocationResponse: Codable {
    let success: Bool
    let data: SearchLocationData?
    let error: String?
}

struct SearchLocationData: Codable {
    let zzimCardResponses: [SearchLocationResult]
}

struct SearchLocationResult: Codable, Identifiable {
    var id = UUID()
    let locationId: Int
    let placeId: Int?     
    let title: String
    let address: String
    let postTitle: String?
    let description: String?
    let photoUrl: String?
    let latitude: Double?
    let longitude: Double?
    let categoryColorResponse: SearchCategoryColorResponse?
}

struct SearchCategoryColorResponse: Codable {
    let categoryId: Int
    let categoryName: String
    let iconUrl: String
    let iconTextColor: String
    let iconBackgroundColor: String
}

extension SearchLocationResponse {
    func toEntity() -> [SearchLocationResult] {
        return data?.zzimCardResponses ?? []
    }
}

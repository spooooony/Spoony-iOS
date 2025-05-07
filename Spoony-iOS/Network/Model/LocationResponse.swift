//
//  SearchResponse.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/21/25.
//

import Foundation

struct SearchListResponse: Codable {
    let locationResponseList: [SearchResponse]
}

struct SearchResponse: Codable {
    let locationId: Int
    let locationName: String
    let locationAddress: String?
    let locationType: SearchLocationType
    let longitude: Double?
    let latitude: Double?
}

struct SearchLocationType: Codable {
    let locationTypeId: Int
    let locationTypeName: String
    let scope: Double
}

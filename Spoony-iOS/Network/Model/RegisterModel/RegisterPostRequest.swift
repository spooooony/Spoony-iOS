//
//  RegisterPostRequest.swift
//  Spoony-iOS
//
//  Created by 최안용 on 1/22/25.
//

import Foundation

struct RegisterPostRequest: Codable {
    let userId: Int
    let title: String
    let description: String
    let placeName: String
    let placeAddress: String
    let placeRoadAddress: String
    let latitude: Double
    let longitude: Double
    let categoryId: Int
    let menuList: [String]
}

//
//  RegisterPostRequestDTO.swift
//  Spoony-iOS
//
//  Created by 최안용 on 1/22/25.
//

import Foundation

struct RegisterPostRequestDTO: Codable {
    let title: String
    let description: String
    let value: Double
    let cons: String?
    let placeName: String
    let placeAddress: String
    let placeRoadAddress: String
    let latitude: Double
    let longitude: Double
    let categoryId: Int
    let menuList: [String]
}

extension RegisterPostRequestDTO {
    static func toDTO(from info: RegisterEntity) -> Self {
        return .init(
            title: info.title,
            description: info.description,
            value: info.value,
            cons: info.cons,
            placeName: info.placeName,
            placeAddress: info.placeAddress,
            placeRoadAddress: info.placeRoadAddress,
            latitude: info.latitude,
            longitude: info.longitude,
            categoryId: info.categoryId,
            menuList: info.menuList
        )
    }
}

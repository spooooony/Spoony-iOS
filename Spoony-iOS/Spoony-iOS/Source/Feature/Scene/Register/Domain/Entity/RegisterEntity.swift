//
//  RegisterEntity.swift
//  Spoony
//
//  Created by 최안용 on 10/13/25.
//

import Foundation

struct RegisterEntity {
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

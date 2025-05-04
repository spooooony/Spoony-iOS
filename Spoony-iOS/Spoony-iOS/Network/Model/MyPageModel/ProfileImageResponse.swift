//
//  ProfileImageResponse.swift
//  Spoony-iOS
//
//  Created by 최안용 on 5/3/25.
//

import Foundation

struct ProfileImageResponse: Codable {
    let images: [ImageResponse]
}

struct ImageResponse: Codable {
    let imageLevel: Int
    let unlockCondition: String
    let imageUrl: String
    let isUnlocked: Bool
}

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

extension ProfileImageResponse {
    func toModel() -> [ProfileImage] {
        return images.map {
            ProfileImage(
                url: $0.imageUrl,
                imageLevel: $0.imageLevel,
                unlockCondition: $0.unlockCondition,
                isUnlocked: $0.isUnlocked
            )
        }
    }
}

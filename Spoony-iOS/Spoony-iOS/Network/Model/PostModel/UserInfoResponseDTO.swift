//
//  UserInfoResponseDTO.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/28/25.
//

import Foundation

// MARK: - UserData

struct UserInfoResponseDTO: Codable, Equatable {
    let userId: Int
    let platform: String
    let platformId: String
    let userName: String
    let regionName: String?
    let introduction: String?
    let createdAt: String
    let updatedAt: String
    let followerCount: Int
    let followingCount: Int
    let isFollowing: Bool
    let reviewCount: Int
    let profileImageUrl: String
}

//
//  UserInfoResponse.swift
//  Spoony-iOS
//
//  Created by 최안용 on 5/3/25.
//

import Foundation

struct UserInfoResponse: Codable {
    let userId: Int
    let platform: String
    let platformId: String
    let userName: String
    let regionName: String?
    let introduction: String
    let createdAt: String
    let updatedAt: String
    let followerCount: Int
    let followingCount: Int
    let isFollowing: Bool
    let reviewCount: Int
    let profileImageUrl: String
}

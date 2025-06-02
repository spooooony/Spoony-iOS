//
//  FollowResponseModel.swift
//  Spoony-iOS
//
//  Created by 이명진 on 4/23/25.
//

import Foundation

struct FollowListDTO: Codable, Equatable {
    let count: Int
    let users: [FollowUserDTO]
}

struct FollowUserDTO: Codable, Equatable {
    let userId: Int
    let username: String
    let regionName: String?
    let isFollowing: Bool
    let profileImageUrl: String
}

extension FollowListDTO {
    static let sample = FollowListDTO(
        count: 6,
        users: [
            FollowUserDTO(userId: 1, username: "배가희", regionName: "마포구", isFollowing: true, profileImageUrl: "https://example.com/profile1.png"),
            FollowUserDTO(userId: 2, username: "최주리", regionName: "은평구", isFollowing: true, profileImageUrl: "https://example.com/profile2.png"),
            FollowUserDTO(userId: 3, username: "이지훈", regionName: "강남구", isFollowing: false, profileImageUrl: "https://example.com/profile3.png"),
            FollowUserDTO(userId: 4, username: "최안용", regionName: "어쩌라구", isFollowing: false, profileImageUrl: "https://example.com/profile4.png"),
            FollowUserDTO(userId: 5, username: "양수정", regionName: "서대문구", isFollowing: true, profileImageUrl: "https://example.com/profile5.png"),
            FollowUserDTO(userId: 6, username: "김세은", regionName: "용산구", isFollowing: true, profileImageUrl: "https://example.com/profile6.png")
        ]
    )
}

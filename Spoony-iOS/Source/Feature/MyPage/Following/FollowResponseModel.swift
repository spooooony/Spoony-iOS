//
//  FollowResponseModel.swift
//  Spoony-iOS
//
//  Created by 이명진 on 4/23/25.
//

import Foundation

struct FollowResponseModel: Codable {
    let follows: [FollowModel]
}

struct FollowModel: Codable {
    let userId: Int
    let username: String
    let location: String
    let isFollowing: Bool
}

extension FollowModel {
    static func dummyData() -> [FollowModel] {
        return [
            FollowModel(userId: 1, username: "배가희", location: "마포구", isFollowing: true),
            FollowModel(userId: 2, username: "최주리", location: "은평구", isFollowing: true),
            FollowModel(userId: 3, username: "이지훈", location: "강남구", isFollowing: false),
            FollowModel(userId: 4, username: "최안용", location: "어쩌라구", isFollowing: false),
            FollowModel(userId: 5, username: "양수정", location: "서대문구", isFollowing: true),
            FollowModel(userId: 6, username: "김세은", location: "용산구", isFollowing: true)
        ]
    }
}

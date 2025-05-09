//
//  BlockedUserModel.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 5/7/25.
//

import Foundation

struct BlockedUsersResponse: Codable {
    let users: [BlockedUserModel]
}

struct BlockedUserModel: Codable, Identifiable, Equatable {
    var id: Int { userId }
    let userId: Int
    let username: String
    let regionName: String
    let profileImageUrl: String
}

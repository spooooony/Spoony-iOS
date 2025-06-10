//
//  UserSimpleResponse.swift
//  Spoony-iOS
//
//  Created by 최주리 on 5/6/25.
//

import Foundation

struct UserSimpleListResponse: Codable {
    let userSimpleResponseDTO: [UserSimpleResponse]
}

extension UserSimpleListResponse {
    struct UserSimpleResponse: Codable {
        let userId: Int
        let username: String
        let regionName: String?
        let profileImageUrl: String
        let isMine: Bool
    }
}

extension UserSimpleListResponse {
    func toEntity() -> [SimpleUser] {
        return userSimpleResponseDTO.map {
            .init(
                id: $0.userId,
                userName: $0.username,
                regionName: $0.regionName,
                profileImage: $0.profileImageUrl,
                isMine: $0.isMine
            )
        }
    }
}

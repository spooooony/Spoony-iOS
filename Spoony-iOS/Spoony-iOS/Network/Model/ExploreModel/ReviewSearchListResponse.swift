//
//  ReviewSearchListResponse.swift
//  Spoony-iOS
//
//  Created by 최주리 on 5/6/25.
//

import Foundation

struct ReviewSearchListResponse: Codable {
    let postSearchResultList: [ReviewSearchResponse]
}

extension ReviewSearchListResponse {
    struct ReviewSearchResponse: Codable {
        let userId: Int
        let userName: String
        let userRegion: String?
        let postId: Int
        let description: String
        let categoryColorResponse: CategoryColorResponse
        let zzimCount: Int
        let photoUrlList: [String]
        let createdAt: String
    }
}

extension ReviewSearchListResponse {
    func toEntity() -> [FeedEntity] {
        return postSearchResultList.map {
            .init(
                id: UUID(),
                postId: $0.postId,
                userName: $0.userName,
                userRegion: $0.userRegion,
                description: $0.description,
                categorColorResponse: $0.categoryColorResponse,
                zzimCount: $0.zzimCount,
                photoURLList: $0.photoUrlList,
                createAt: $0.createdAt
            )
        }
    }
}

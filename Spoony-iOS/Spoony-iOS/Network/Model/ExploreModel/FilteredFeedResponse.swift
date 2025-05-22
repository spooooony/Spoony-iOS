//
//  FilteredFeedResponse.swift
//  Spoony-iOS
//
//  Created by 최주리 on 5/11/25.
//

import Foundation

struct FilteredFeedResponse: Codable {
    let filteredFeedResponseDTOList: [FeedResponse]
    let nextCursor: Int
}

extension FilteredFeedResponse {
    func toEntity() -> [FeedEntity] {
        filteredFeedResponseDTOList.map { feed in
                .init(
                    id: UUID(),
                    postId: feed.postId,
                    userName: feed.userName,
                    userRegion: feed.userRegion,
                    description: feed.description,
                    categorColorResponse: feed.categoryColorResponse,
                    zzimCount: feed.zzimCount,
                    photoURLList: feed.photoUrlList,
                    createAt: feed.createdAt
                )
        }
    }
}

//
//  FeedEntity.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/22/25.
//

import Foundation

struct FeedEntity: Identifiable, Hashable {
    static func == (lhs: FeedEntity, rhs: FeedEntity) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UUID
    let postId: Int
    let userName: String
    let userRegion: String
    let description: String
    let categorColorResponse: CategoryColorResponse
    let zzimCount: Int
    let photoURLList: [String]
    let createAt: String
    let isMine: Bool
    
    init(
        id: UUID,
        postId: Int,
        userName: String,
        userRegion: String,
        description: String,
        categorColorResponse: CategoryColorResponse,
        zzimCount: Int,
        photoURLList: [String],
        createAt: String,
        isMine: Bool = false
    ) {
        self.id = id
        self.postId = postId
        self.userName = userName
        self.userRegion = userRegion
        self.description = description
        self.categorColorResponse = categorColorResponse
        self.zzimCount = zzimCount
        self.photoURLList = photoURLList
        self.createAt = createAt
        self.isMine = isMine
    }
}

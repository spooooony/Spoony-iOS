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
}

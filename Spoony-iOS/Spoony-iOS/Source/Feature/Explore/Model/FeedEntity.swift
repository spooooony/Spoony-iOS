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
    let userName: String
    let userRegion: String
    let title: String
    let categorColorResponse: CategoryColorResponse
    let zzimCount: Int
}



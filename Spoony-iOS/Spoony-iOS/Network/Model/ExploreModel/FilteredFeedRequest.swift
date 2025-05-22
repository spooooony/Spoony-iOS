//
//  FilteredFeedRequest.swift
//  Spoony-iOS
//
//  Created by 최주리 on 5/11/25.
//

import Foundation

struct FilteredFeedRequest: Codable {
    let isLocal: Bool
    let categoryIds: [Int]
    let regionIds: [Int]
    let ageGroups: [String]
    let sortBy: String
    let cursor: Int
    let size: Int
}

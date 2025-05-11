//
//  FeedFilteredRequest.swift
//  Spoony-iOS
//
//  Created by 최주리 on 5/11/25.
//

import Foundation

struct FeedFilteredRequest: Codable {
    let isLocal: Bool
    let categoryIds: [Int]
    let regionIds: [Int]
    let ageGroups: [String]
    let sortBy: String
}

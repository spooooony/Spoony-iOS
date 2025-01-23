//
//  DetailIntent.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/23/25.
//

import Foundation

// MARK: - Intent

enum DetailIntent {
    case getInitialValue(userId: Int, postId: Int)
    case scoopButtonDidTap
    case scrapButtonDidTap(isScrap: Bool)
    case addButtonDidTap
    case pathInfoInNaverMaps
}

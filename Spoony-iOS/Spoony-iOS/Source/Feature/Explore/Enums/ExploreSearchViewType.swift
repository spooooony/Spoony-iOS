//
//  ExploreSearchViewType.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/20/25.
//

import Foundation

enum ExploreSearchViewType {
    case user
    case review
    
    var description: String {
        switch self {
        case .user:
            "팔로우 하고 싶은 유저를 검색해 보세요"
        case .review:
            "원하는 키워드를 검색해 보세요"
        }
    }
    
    var placeholder: String {
        switch self {
        case .user:
            "유저 닉네임으로 검색"
        case .review:
            "리뷰 키워드로 검색"
        }
    }
    
    var emptyDescription: String {
        switch self {
        case .user:
            "정확한 닉네임을 입력해 보세요"
        case .review:
            "정확한 키워드를 입력해 보세요"
        }
    }
    
    var recentSearches: [String] {
        switch self {
        case .user:
            UserManager.shared.exploreUserRecentSearches ?? []
        case .review:
            UserManager.shared.exploreReviewRecentSearches ?? []
        }
    }
}

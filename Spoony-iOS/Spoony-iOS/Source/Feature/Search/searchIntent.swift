//
//  searchIntent.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/24/25.
//

import Foundation

enum SearchIntent {
    case updateSearchText(String)
    case search
    case clearSearch
    case removeRecentSearch(String)
    case clearAllRecentSearches
    case selectLocation(SearchResult)
    case setFirstAppear(Bool)
}

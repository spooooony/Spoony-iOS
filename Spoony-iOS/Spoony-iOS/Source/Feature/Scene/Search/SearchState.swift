//
//  SearchState.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/16/25.
//

import Foundation

enum SearchState: Equatable {
    case empty
    case typing(searchText: String)
    case loading
    case success(results: [SearchResult])
    case error(message: String)
    
    static func == (lhs: SearchState, rhs: SearchState) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty):
            return true
        case let (.typing(lhsText), .typing(rhsText)):
            return lhsText == rhsText
        case (.loading, .loading):
            return true
        case let (.success(lhsResults), .success(rhsResults)):
            return lhsResults == rhsResults
        case let (.error(lhsMessage), .error(rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
    
    var results: [SearchResult] {
        if case let .success(results) = self {
            return results
        }
        return []
    }
}

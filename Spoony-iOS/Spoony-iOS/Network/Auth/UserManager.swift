//
//  UserManager.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/19/25.
//

import Foundation

final class UserManager {
    @UserDefaultWrapper<String>(key: "userId") public var userId
    
    @UserDefaultWrapper(key: "RecentSearches") public var recentSearches: [String]?
    
    @UserDefaultWrapper(key: "exploreUserRecentSearches") public var exploreUserRecentSearches: [String]?
    @UserDefaultWrapper(key: "exploreReviewRecentSearches") public var exploreReviewRecentSearches: [String]?
    
    static let shared = UserManager()
    
    private init() { }
    
    func setSearches(_ key: String, _ text: String) {
        var list: [String]?
        
        switch key {
        case "exploreUserRecentSearches":
            list = exploreUserRecentSearches ?? []
        case "exploreReviewRecentSearches":
            list = exploreReviewRecentSearches ?? []
        default:
            return
        }
        
        if let index = list?.firstIndex(of: text) {
            list?.remove(at: index)
        } else if list?.count == 6 {
            list?.removeLast()
        }
        
        list?.insert(text, at: 0)
        
        switch key {
        case "exploreUserRecentSearches":
            exploreUserRecentSearches = list
        case "exploreReviewRecentSearches":
            exploreReviewRecentSearches = list
        default:
            return
        }
    }
    
    func deleteRecent(_ key: String, _ text: String) {
        switch key {
        case "exploreUserRecentSearches":
            guard let index = exploreUserRecentSearches?.firstIndex(of: text)
            else { return }
            
            exploreUserRecentSearches?.remove(at: index)
        case "exploreReviewRecentSearches":
            guard let index = exploreReviewRecentSearches?.firstIndex(of: text)
            else { return }
            
            exploreReviewRecentSearches?.remove(at: index)
        default:
            return
        }
    }
}

// TODO: 리터럴 -> enum key값 관리하기
// 여러 파일 건들여야 해서 추후 수정 하겠습니다 !
enum UserDefaultsKey: String {
    case userId
    case recentSearches
    case exploreUserRecentSearches
    case exploreReviewRecentSearches
}

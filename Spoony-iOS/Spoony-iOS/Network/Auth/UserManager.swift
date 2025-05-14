//
//  UserManager.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/19/25.
//

import Foundation

enum UserDefaultsKeys: String, CaseIterable {
    case userId = "userId"
    case isTooltipPresented = "isTooltipPresented"
    case recentSearches = "RecentSearches"
    case exploreUserRecentSearches = "exploreUserRecentSearches"
    case exploreReviewRecentSearches = "exploreReviewRecentSearches"
}

final class UserManager {
    @UserDefaultWrapper(key: .userId) public var userId: String?
    @UserDefaultWrapper(key: .isTooltipPresented) public var isTooltipPresented: Bool?
    @UserDefaultWrapper(key: .recentSearches) public var recentSearches: [String]?
    
    @UserDefaultWrapper(key: .exploreUserRecentSearches) public var exploreUserRecentSearches: [String]?
    @UserDefaultWrapper(key: .exploreReviewRecentSearches) public var exploreReviewRecentSearches: [String]?
    
    static let shared = UserManager()
    
    private init() { }
    
    func setSearches(_ key: SearchType, _ text: String) {
        var list: [String]?
        
        switch key {
        case .user:
            list = exploreUserRecentSearches ?? []
        case .review:
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
        case .user:
            exploreUserRecentSearches = list
        case .review:
            exploreReviewRecentSearches = list
        default:
            return
        }
    }
    
    func deleteRecent(_ key: SearchType, _ text: String) {
        switch key {
        case .user:
            guard let index = exploreUserRecentSearches?.firstIndex(of: text)
            else { return }
            
            exploreUserRecentSearches?.remove(at: index)
        case .review:
            guard let index = exploreReviewRecentSearches?.firstIndex(of: text)
            else { return }
            
            exploreReviewRecentSearches?.remove(at: index)
        default:
            return
        }
    }
    
    func clearAllUserDefaults() {
        UserDefaultsKeys.allCases.forEach { key in
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
        
        userId = nil
        isTooltipPresented = nil
        recentSearches = nil
        exploreUserRecentSearches = nil
        exploreReviewRecentSearches = nil
    }
}

enum SearchType {
    case map
    case user
    case review
}

//
//  UserManager.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/19/25.
//

import Foundation

enum UserDefaultsKeys: String, CaseIterable {
    case userId = "userId"
    case recentSearches = "RecentSearches"
    case exploreUserRecentSearches = "exploreUserRecentSearches"
    case exploreReviewRecentSearches = "exploreReviewRecentSearches"
    case lastAppVisitDate = "lastAppVisitDate"
    case hasCompletedOnboarding = "hasCompletedOnboarding"
    case lastHomeVisitDate = "lastHomeVisitDate"
    case isFirstOpen = "isFirstOpen"
}

final class UserManager {
    @UserDefaultWrapper(key: .userId) public var userId: String?
    @UserDefaultWrapper(key: .recentSearches) public var recentSearches: [String]?
    
    @UserDefaultWrapper(key: .exploreUserRecentSearches) public var exploreUserRecentSearches: [String]?
    @UserDefaultWrapper(key: .exploreReviewRecentSearches) public var exploreReviewRecentSearches: [String]?
    @UserDefaultWrapper(key: .lastAppVisitDate) public var lastAppVisitDate: Date?
    
    @UserDefaultWrapper(key: .hasCompletedOnboarding) public var hasCompletedOnboarding: Bool?
    
    @UserDefaultWrapper(key: .lastHomeVisitDate) private var lastHomeVisitDate: Date?
    @UserDefaultWrapper(key: .isFirstOpen) private var isFirstOpen: Bool?
    
    static let shared = UserManager()
    
    private init() { }
    
    func isFirstOpenApp() -> Bool {
        guard let isFirstOpen = isFirstOpen else {
            self.isFirstOpen = true
            return true
        }
        return !isFirstOpen
    }
    
    func setSearches(_ key: SearchType, _ text: String) {
        var list: [String]?
        
        switch key {
        case .map:
            list = recentSearches ?? []
        case .user:
            list = exploreUserRecentSearches ?? []
        case .review:
            list = exploreReviewRecentSearches ?? []
        }
        
        if let index = list?.firstIndex(of: text) {
            list?.remove(at: index)
        } else if list?.count == 6 {
            list?.removeLast()
        }
        
        list?.insert(text, at: 0)
        
        switch key {
        case .map:
            recentSearches = list
        case .user:
            exploreUserRecentSearches = list
        case .review:
            exploreReviewRecentSearches = list
        }
    }

    func deleteRecent(_ key: SearchType, _ text: String) {
        switch key {
        case .map:
            guard let index = recentSearches?.firstIndex(of: text)
            else { return }
            
            recentSearches?.remove(at: index)
        case .user:
            guard let index = exploreUserRecentSearches?.firstIndex(of: text)
            else { return }
            
            exploreUserRecentSearches?.remove(at: index)
        case .review:
            guard let index = exploreReviewRecentSearches?.firstIndex(of: text)
            else { return }
            
            exploreReviewRecentSearches?.remove(at: index)
        }
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        updateLastVisitDate()
    }
    
    func isFirstVisitOfDay() -> Bool {
        guard hasCompletedOnboarding == true else {
            return false
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastVisitDate = lastAppVisitDate {
            let lastVisitDay = Calendar.current.startOfDay(for: lastVisitDate)
            
            if lastVisitDay < today {
                lastAppVisitDate = today
                return true
            }
            return false
        } else {
            lastAppVisitDate = today
            return true
        }
    }
    
    func updateLastVisitDate() {
        lastAppVisitDate = Calendar.current.startOfDay(for: Date())
    }
    
    func hasVisitedHomeToday() -> Bool {
        guard hasCompletedOnboarding == true else {
            return false
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastHomeVisit = lastHomeVisitDate {
            let lastHomeVisitDay = Calendar.current.startOfDay(for: lastHomeVisit)
            return lastHomeVisitDay == today
        }
        
        return false
    }
    
    func setHomeVisitedToday() {
        lastHomeVisitDate = Calendar.current.startOfDay(for: Date())
    }
    
    func resetHomeVisitDate() {
        lastHomeVisitDate = nil
    }
}

enum SearchType {
    case map
    case user
    case review
}

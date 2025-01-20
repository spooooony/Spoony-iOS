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
    
    static let shared = UserManager()
    
    private init() { }
}

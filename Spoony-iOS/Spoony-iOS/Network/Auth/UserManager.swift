//
//  UserManager.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/19/25.
//

import Foundation

final class UserManager {
    @UserDefaultWrapper<String>(key: "userId") public var userId
    
    static let shared = UserManager()
    
    private init() { }
}

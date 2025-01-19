//
//  UserDefaultWrapper.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/19/25.
//

import Foundation

@propertyWrapper struct UserDefaultWrapper<T> {
    
    var wrappedValue: T? {
        get {
            return UserDefaults.standard.object(forKey: self.key) as? T
        }
        
        set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: key)
            } else { UserDefaults.standard.setValue(newValue, forKey: key) }
        }
    }
    
    private let key: String
    
    init(key: String) {
        self.key = key
    }
}

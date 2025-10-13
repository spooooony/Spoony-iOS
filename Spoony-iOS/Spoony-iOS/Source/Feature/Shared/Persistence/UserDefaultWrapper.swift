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
            return UserDefaults.standard.object(forKey: self.key.rawValue) as? T
        }
        
        set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: key.rawValue)
            } else {
                UserDefaults.standard.setValue(newValue, forKey: key.rawValue)
            }
        }
    }
    
    private let key: UserDefaultsKeys
    
    init(key: UserDefaultsKeys) {
        self.key = key
    }
}

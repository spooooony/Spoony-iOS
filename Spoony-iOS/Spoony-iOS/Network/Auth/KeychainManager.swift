//
//  KeychainManager.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/24/25.
//

import Foundation

enum KeychainType: String {
    case accessToken
    case refreshToken
}

struct KeychainManager {
    private init() { }
    
    static func create(key: KeychainType, value: String) {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: value
        ]
        SecItemDelete(query)
        
        let status = SecItemAdd(query, nil)
        
        assert(status == noErr, "key chain create failed")
    }
    
    static func read(key: KeychainType) -> String? {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: kCFBooleanTrue as Any // CFData 타입으로 불러오라는 의미
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        
        if status == errSecSuccess {
            guard let data = result as? Data,
                  let value = String(data: data, encoding: String.Encoding.utf8)
            else { return nil }
            
            return value
        } else {
            print("key chain read failed")
            return nil
        }
    }
    
    static func delete(key: KeychainType) {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        
        let status = SecItemDelete(query)
        
        assert(status == noErr, "key chain delete failed")
    }
}

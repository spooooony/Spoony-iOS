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
    case socialType
}

enum KeychainError: Error {
    case invalidData
    case failedToCreate
    case failedToRead
    case failedToDelete
}

struct KeychainManager {
    private init() { }
    
    static func create(key: KeychainType, value: String) -> Result<Void, KeychainError> {
        guard let data = value.data(using: .utf8)
        else { return .failure(.invalidData) }
        
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue,
            kSecValueData: data
        ]
        SecItemDelete(query)
        
        let status = SecItemAdd(query, nil)
        
        if status == noErr {
            return .success(())
        } else {
            return .failure(.failedToCreate)
        }
    }
    
    static func read(key: KeychainType) -> Result<String?, KeychainError> {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue,
            kSecReturnData: kCFBooleanTrue as Any // CFData 타입으로 불러오라는 의미
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        
        if status == errSecSuccess {
            guard let data = result as? Data,
                  let value = String(data: data, encoding: String.Encoding.utf8)
            else { return .failure(.invalidData) }
            
            return .success(value)
        } else {
            return .failure(.failedToRead)
        }
    }
    
    static func delete(key: KeychainType) -> Result<Void, KeychainError> {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue
        ]
        
        let status = SecItemDelete(query)

        if status == noErr {
            return .success(())
        } else {
            return .failure(.failedToDelete)
        }
    }
}

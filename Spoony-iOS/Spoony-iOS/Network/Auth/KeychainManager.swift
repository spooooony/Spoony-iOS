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
    
    static func read(key: KeychainType) -> String? {
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
            else { return "" }
            
            return value
        } else {
            return ""
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
    
    static func saveKeychain(access: String, refresh: String, platform: String) {
        switch KeychainManager.create(key: .accessToken, value: access) {
        case .success:
            print("✅ Access Token saved successfully")
        case .failure(let error):
            print("❌ Access Token save failed: \(error)")
        }
        
        switch KeychainManager.create(key: .refreshToken, value: refresh) {
        case .success:
            print("✅ Refresh Token saved successfully")
        case .failure(let error):
            print("❌ Refresh Token save failed: \(error)")
        }
        
        switch KeychainManager.create(key: .socialType, value: platform) {
        case .success:
            print("✅ Refresh Token saved successfully")
        case .failure(let error):
            print("❌ Refresh Token save failed: \(error)")
        }
        
        // 저장 후 바로 읽어보기 테스트
        print("✅ Access Token read test: \(KeychainManager.read(key: .accessToken)?.prefix(30) ?? "nil")")
    }
}

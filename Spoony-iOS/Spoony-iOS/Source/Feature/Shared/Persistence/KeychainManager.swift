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
            kSecReturnData: kCFBooleanTrue as Any,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            print("⛔️ Keychain read failed with status: \(status)")
            return nil
        }
        
        return value
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
        print("✅ Access Token \(KeychainManager.read(key: .accessToken) ?? "")")
        print("✅ Refresh Token \(KeychainManager.read(key: .refreshToken) ?? "")")
    }
}

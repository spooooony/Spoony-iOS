//
//  HeaderType.swift
//  Spoony-iOS
//
//  Created by 최주리 on 5/3/25.
//

import Foundation

enum HeaderType {
    case noAuth     // authorization 불필요 시 사용
    case auth       // authorization 필요 시 사용
    case token(String)      // 소셜 로그인 -> 서버 로그인 토큰 전달 시 사용
    
    var value: [String: String]? {
        switch self {
        case .noAuth:
            return [
                "Content-Type": "application/json"
            ]
            // 여기 토큰 바꾸기
        case .auth:
            switch KeychainManager.read(key: .accessToken) {
            case .success(let token):
                guard let token else {
                    print("Access Token Nil Error")
                    return [:]
                }
                
                return [
                    "Content-Type": "application/json",
                    "Authorization": "Bearer \(token)"
                ]
            case .failure(let error):
                print("Keychain Read Error: \(error)")
                return [:]
            }
        case .token(let token):
            return [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(token)"
            ]
        }
    }
}

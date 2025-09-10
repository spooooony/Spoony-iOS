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
    case multipart
    
    var value: [String: String]? {
        switch self {
        case .noAuth:
            return ["Content-Type": "application/json"]
        case .auth:
            if let token = TokenManager.shared.currentToken {
                return [
                    "Content-Type": "application/json",
                    "Authorization": "Bearer \(token)"
                ]
            } else {
                print("⛔️ Key chain Error")
                return [:]
            }
        case .token(let token):
            return [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(token)"
            ]
        case .multipart:
            if let token = TokenManager.shared.currentToken {
                return [
                    "Content-Type": "multipart/form-data",
                    "Authorization": "Bearer \(token)"
                ]
            } else {
                print("⛔️ Key chain Error")
                return [:]
            }
        }
    }
}

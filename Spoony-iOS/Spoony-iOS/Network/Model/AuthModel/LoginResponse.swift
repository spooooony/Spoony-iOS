//
//  LoginResponse.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/24/25.
//

import Foundation

struct LoginResponse: Codable {
    let exists: Bool
    let jwtTokenDto: JWTResponse?
}

extension LoginResponse {
    struct JWTResponse: Codable {
        let accessToken: String
        let refreshToken: String
    }
}

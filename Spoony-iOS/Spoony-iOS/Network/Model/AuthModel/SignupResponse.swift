//
//  SignupResponse.swift
//  Spoony-iOS
//
//  Created by 최주리 on 5/3/25.
//

import Foundation

struct SignupResponse: Codable {
    let user: UserResponse
    let jwtTokenDto: JWTResponse
}

extension SignupResponse {
    struct UserResponse: Codable {
        let userId: Int
        let platform: String
        let platformId: String
        let imageLevel: Int
        let level: Int
        let userName: String
        let region: RegionResponse?
        let introduction: String?
        let birth: String?
    }
    
    struct RegionResponse: Codable {
        let regionId: Int
        let regionName: String
    }
    
    struct JWTResponse: Codable {
        let accessToken: String
        let refreshToken: String
    }
}

extension SignupResponse.UserResponse {
    func toEntity() -> OnboardingUserEntity {
        return .init(
            userName: userName,
            region: region?.toEntity(),
            introduction: introduction,
            birth: birth
        )
    }
}

extension SignupResponse.RegionResponse {
    func toEntity() -> RegionEntity {
        return .init(regionID: regionId, regionName: regionName)
    }
}

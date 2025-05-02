//
//  LoginResponse.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/24/25.
//

import Foundation

struct LoginResponse: Codable {
    let exists: Bool
    let user: UserResponse
    let jwtTokenDto: JWTResponse
}

extension LoginResponse {
    struct UserResponse: Codable {
        let userId: Int
        let platform: String
        let platformId: String
        let imageLevel: Int
        let level: Int
        let userName: String
        let region: RegionResponse
        let introduction: String
        let birth: String
        let createdAt: String
        let updatedAt: String
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

extension LoginResponse {
    func toEntity() -> LoginUserEntity {
        return .init(
            userID: user.userId,
            imageLevel: user.imageLevel,
            level: user.level,
            userName: user.userName,
            region: user.region.toEntity()
        )
    }
}

extension LoginResponse.RegionResponse {
    func toEntity() -> RegionEntity {
        return .init(regionID: regionId, regionName: regionName)
    }
}

// TODO:  임시 객체 폴더 이동하기
struct LoginUserEntity {
    let userID: Int
    let imageLevel: Int
    let level: Int
    let userName: String
    let region: RegionEntity
}

struct RegionEntity {
    let regionID: Int
    let regionName: String
}

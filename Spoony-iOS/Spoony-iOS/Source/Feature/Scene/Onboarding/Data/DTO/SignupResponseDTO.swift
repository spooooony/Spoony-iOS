//
//  SignupResponseDTO.swift
//  Spoony-iOS
//
//  Created by 최주리 on 5/3/25.
//

import Foundation

struct UserEntity {
    let userID: Int
    let imageLevel: Int
    let level: Int
    let userName: String
    let region: Region?
    let introduction: String?
    let birth: String?
}

struct SignupResponseDTO: Codable {
    let user: UserResponse
    let jwtTokenDto: JWTResponse
}

extension SignupResponseDTO {
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
    
    struct JWTResponse: Codable {
        let accessToken: String
        let refreshToken: String
    }
}

extension SignupResponseDTO.UserResponse {
    struct RegionResponse: Codable {
        let regionId: Int
        let regionName: String
    }
}

extension SignupResponseDTO.UserResponse.RegionResponse {
    func toEntity() -> Region {
        .init(id: regionId, regionName: regionName)
    }
}

extension SignupResponseDTO.UserResponse {
    func toEntity() -> UserEntity {
        .init(
            userID: userId,
            imageLevel: imageLevel,
            level: level,
            userName: userName,
            region: region?.toEntity(),
            introduction: introduction,
            birth: birth
        )
    }
}

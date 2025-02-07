//
//  UserInfoResponseDTO.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/28/25.
//

import Foundation

// MARK: - UserData

struct UserInfoResponseDTO: Codable {
    let userId: Int
    let userEmail: String
    let userName: String
    let userImageUrl: String
    let regionName: String
    let createdAt: String
    let updatedAt: String
}

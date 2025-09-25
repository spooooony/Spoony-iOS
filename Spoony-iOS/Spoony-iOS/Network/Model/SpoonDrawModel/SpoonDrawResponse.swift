//
//  SpoonModels.swift
//  Spoony-iOS
//
//  Created on 5/20/25.
//

import Foundation

struct SpoonDrawResponseWrapper: Codable, Equatable {
    let success: Bool
    let data: SpoonDrawData?
    let error: APIError?
    
    struct SpoonDrawData: Codable, Equatable {
        let spoonDrawResponseDTOList: [SpoonDrawResponse]
        let spoonBalance: Int
        let weeklyBalance: Int
    }
    
    struct APIError: Codable, Equatable {
        let message: String
    }
}

struct SpoonDrawResponse: Codable, Equatable {
    let drawId: Int
    let spoonType: SpoonType
    let localDate: String
    let weekStartDate: String
    let createdAt: String
}

struct SpoonType: Codable, Equatable {
    let spoonTypeId: Int
    let spoonName: String
    let spoonAmount: Int
    let probability: Double
    let spoonImage: String
    let spoonGetImage: String
}

struct SpoonCountResponse: Codable {
    let spoonAmount: Int
}

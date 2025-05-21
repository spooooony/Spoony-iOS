//
//  SpoonModels.swift
//  Spoony-iOS
//
//  Created on 5/20/25.
//

import Foundation

// 스푼 뽑기 응답 모델
struct SpoonDrawResponse: Codable, Equatable {
    let drawId: Int
    let spoonType: SpoonType
    let localDate: String
    let weekStartDate: String
    let createdAt: String
}

// 스푼 타입 모델
struct SpoonType: Codable, Equatable {
    let spoonTypeId: Int
    let spoonName: String
    let spoonAmount: Int
    let probability: Double
    let spoonImage: String
}

// 이미 있는 스푼 카운트 응답 모델과 이름을 다르게 설정 (충돌 해결)
struct SpoonCountResponse: Codable {
    let spoonAmount: Int
}

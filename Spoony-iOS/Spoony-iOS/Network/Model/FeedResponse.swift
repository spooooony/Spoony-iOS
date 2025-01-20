//
//  FeedResponse.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/20/25.
//

import Foundation

struct FeedResponse: Codable {
    let userId: Int
    let userName: String
    let createdAt: String
    let userRegion: String
    let title: String
    let categorColorResponseDTO: CategoryColorResponse
    let zzimCount: Int
    
    func translate() -> FeedEntity {
        .init(
            id: UUID(),
            userName: self.userName,
            userRegion: self.userRegion,
            title: self.title,
            categorColorResponseDTO: self.categorColorResponseDTO,
            zzimCount: self.zzimCount
        )
    }
}

struct CategoryColorResponse: Codable, Hashable {
    let categoryName: String
    let iconUrl: String
    let iconTextColor: String
    let iconBackgroundColor: String
}

struct FeedEntity: Identifiable, Hashable {
    
    static func == (lhs: FeedEntity, rhs: FeedEntity) -> Bool {
        lhs.id == rhs.id
    }
    let id: UUID
    let userName: String
    let userRegion: String
    let title: String
    let categorColorResponseDTO: CategoryColorResponse
    let zzimCount: Int
}

// MARK: - SAMPLE
extension FeedResponse {
    static let sample: FeedResponse = .init(
        userId: 1,
        userName: "안용아안용",
        createdAt: "2025-01-19T22:58:53.622066",
        userRegion: "서울시 성북구",
        title: "테스트 title",
        categorColorResponseDTO: .init(
            categoryName: "로컬 수저",
            iconUrl: "url",
            iconTextColor: "hexa code",
            iconBackgroundColor: "hexa code"
        ),
        zzimCount: 1
    )
}

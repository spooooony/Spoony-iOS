//
//  SearchResult.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/16/25.
//

import Foundation

struct SearchResult: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let locationId: Int
    let address: String
}

struct Location: Equatable {
    let title: String
    let id: Int
    let latitude: Double
    let longitude: Double
    
    init(title: String, id: Int, latitude: Double, longitude: Double) {
        self.title = title
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(searchResult: SearchResult) {
        self.title = searchResult.title
        self.id = searchResult.locationId
        // 검색 결과에서는 기본 위치 사용
        self.latitude = 37.5666103  // 서울시청 위도
        self.longitude = 126.9783882 // 서울시청 경도
    }
}

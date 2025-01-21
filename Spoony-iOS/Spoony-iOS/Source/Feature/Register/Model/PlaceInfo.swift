//
//  PlaceInfo.swift
//  Spoony-iOS
//
//  Created by 최안용 on 1/17/25.
//

import Foundation

struct PlaceInfo {
    let id = UUID()
    let placeName: String
    let placeAddress: String
    let placeRoadAddress: String
    let latitude: Double
    let longitude: Double
}

extension PlaceInfo {
    static func sample() -> [PlaceInfo] {
        return [
//            .init(nameTitle: "신룽푸마라탕 고속터미널점", loaction: "서울 서초구 신반포로 194 지하 1층"),
//            .init(nameTitle: "신룽푸마라탕 신라점", loaction: "서울 중구 신당동 416"),
//            .init(nameTitle: "신룽푸마라탕 보라매점", loaction: "서울 동작구 보라매로5가길 16"),
//            .init(nameTitle: "신룽푸마라탕 보라매점", loaction: "서울 동작구 보라매로5가길 16"),
//            .init(nameTitle: "신룽푸마라탕 보라매점", loaction: "서울 동작구 보라매로5가길 16")
        ]
    }
}

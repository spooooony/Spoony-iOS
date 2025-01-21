//
//  DetailModel.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/20/25.
//

import Foundation

struct ReviewDetailModel: Codable {
    let postId: Int
    let userId: Int
    let photoUrlList: [String]
    let title: String
    let date: String
    let menuList: [String]
    let description: String
    let placeName: String
    let placeAddress: String
    let latitude: Double
    let longitude: Double
    let zzimCount: Int
    let isZzim: Bool
    let isScoop: Bool
    let categoryColorResponse: DetailCategoryColorResponse
}

struct DetailCategoryColorResponse: Codable {
    let categoryName: String
    let iconUrl: String
    let iconTextColor: String
    let iconBackgroundColor: String
}

extension ReviewDetailModel {
    static func sample() -> ReviewDetailModel {
        return ReviewDetailModel(
            postId: 4,
            userId: 1,
            photoUrlList: [
                "https://spoony-storage.s3.ap-northeast-2.amazonaws.com/post/%2F34f4b505-3cbb-4a01-9274-9c93989b853cKakaoTalk_20250117_065031294.png",
                "https://spoony-storage.s3.ap-northeast-2.amazonaws.com/post/%2F200495da-23e7-4bdb-8fff-94466a61d58bKakaoTalk_20250117_065031294_01.png",
                "https://spoony-storage.s3.ap-northeast-2.amazonaws.com/post/%2F200495da-23e7-4bdb-8fff-94466a61d58bKakaoTalk_20250117_065031294_01.png"
            ],
            title: "테스트 제목",
            date: "2025-01-18T05:21:36.181697",
            menuList: ["메뉴1", "메뉴2"],
            description: "테스트 설명",
            placeName: "테스트 장소",
            placeAddress: "서울 강남구",
            latitude: 37.497946,
            longitude: 127.027632,
            zzimCount: 12,
            isZzim: false,
            isScoop: false,
            categoryColorResponse: DetailCategoryColorResponse(
                categoryName: "name",
                iconUrl: "url_color_1",
                iconTextColor: "",
                iconBackgroundColor: "background_color_1"
            )
        )
    }
}

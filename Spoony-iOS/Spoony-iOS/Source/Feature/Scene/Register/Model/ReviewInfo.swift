//
//  ReviewInfo.swift
//  Spoony-iOS
//
//  Created by 최안용 on 5/7/25.
//

import Foundation

struct ReviewInfo: Equatable {
    let uploadImages: [UploadImage]
    let menuList: [String]
    let description: String
    let value: Double   
    let cons: String
    let placeName: String
    let placeAddress: String
    let selectedCategoryId: Int
}

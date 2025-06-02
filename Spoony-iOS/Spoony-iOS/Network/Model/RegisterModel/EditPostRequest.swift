//
//  EditPostRequest.swift
//  Spoony-iOS
//
//  Created by 최안용 on 5/7/25.
//

import Foundation

struct EditPostRequest: Codable {
    let postId: Int
    let description: String
    let value: Double
    let cons: String
    let categoryId: Int
    let menuList: [String]
    let deleteImageUrlList: [String]
}

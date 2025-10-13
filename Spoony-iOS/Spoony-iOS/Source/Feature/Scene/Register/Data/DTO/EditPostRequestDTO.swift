//
//  EditPostRequestDTO.swift
//  Spoony-iOS
//
//  Created by 최안용 on 5/7/25.
//

import Foundation

struct EditPostRequestDTO: Codable {
    let postId: Int
    let description: String
    let value: Double
    let cons: String
    let categoryId: Int
    let menuList: [String]
    let deleteImageUrlList: [String]
}

extension EditPostRequestDTO {
    static func toDTO(from info: EditEntity) -> Self {
        return .init(
            postId: info.postId,
            description: info.description,
            value: info.value,
            cons: info.cons,
            categoryId: info.categoryId,
            menuList: info.menuList,
            deleteImageUrlList: info.deleteImageUrlList
        )
    }
}

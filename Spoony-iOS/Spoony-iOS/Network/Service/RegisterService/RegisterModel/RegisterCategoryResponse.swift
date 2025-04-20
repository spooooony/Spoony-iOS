//
//  RegisterCategoryResponse.swift
//  Spoony-iOS
//
//  Created by 최안용 on 1/21/25.
//

import Foundation
import Moya
import Kingfisher

struct RegisterCategoryResponse: Codable {
    let categoryMonoList: [CategoryResponse]
}

struct CategoryResponse: Codable {
    let categoryId: Int
    let categoryName: String
    let iconUrlNotSelected: String
    let iconUrlSelected: String
}

extension RegisterCategoryResponse {
    func toModel() async throws -> [CategoryChip] {
        categoryMonoList.map { category in
                .init(
                    image: category.iconUrlNotSelected,
                    selectedImage: category.iconUrlSelected,
                    title: category.categoryName,
                    id: category.categoryId
                )
        }
    }
}

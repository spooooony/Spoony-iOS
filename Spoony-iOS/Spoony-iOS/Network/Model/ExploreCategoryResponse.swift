//
//  ExploreCategoryResponse.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/21/25.
//

import Foundation

struct SearchCategoryListResponse: Codable {
    let categoryMonoList: [CategoryResponse]
}

extension SearchCategoryListResponse {
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

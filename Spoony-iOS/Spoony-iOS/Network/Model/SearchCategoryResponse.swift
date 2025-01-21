//
//  SearchCategoryResponse.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/21/25.
//

import Foundation

struct SearchCategoryListResponse: Codable {
    let categoryMonoList: [SearchCategoryResponse]
}

struct SearchCategoryResponse: Codable {
    let categoryId: Int
    let categoryName: String
    let iconUrlNotSelected: String
    let iconUrlSelected: String
}

struct CategoryEntity: Identifiable, Equatable {
    let id: Int
    let name: String
    let selectedUrl: String
    let notSelectedUrl: String
}

extension SearchCategoryResponse {
    func toEntity() -> CategoryEntity {
        .init(
            id: self.categoryId,
            name: self.categoryName,
            selectedUrl: self.iconUrlSelected,
            notSelectedUrl: self.iconUrlNotSelected
        )
    }
}

//
//  FilterInfo.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/27/25.
//

import Foundation

struct FilterInfo {
    var local: String
    var categories: [CategoryChip]
    var locations: [String]
    var ages: [String]
    
    init(
        local: String = "로컬 리뷰",
        categories: [CategoryChip],
        locations: [String],
        ages: [String] = ["10대", "20대", "30대", "40대+"]
    ) {
        self.local = local
        self.categories = categories
        self.locations = locations
        self.ages = ages
    }
    
    func items(_ type: FilterType) -> [String] {
        switch type {
        case .local:
            return [local]
        case .category:
            return categories.map { $0.title }
        case .location:
            return locations
        case .age:
            return ages
        }
    }
}

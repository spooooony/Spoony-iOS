//
//  FilterInfo.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/27/25.
//

import Foundation

struct FilterInfo: Equatable {
    var local: String
    var categories: [CategoryChipEntity]
    var locations: [Region]
    var ages: [String]
    
    init(
        local: String = "로컬 리뷰",
        categories: [CategoryChipEntity],
        locations: [Region],
        ages: [String] = AgeType.allCases.map { $0.title }
    ) {
        self.local = local
        self.categories = categories
        self.locations = locations
        self.ages = ages
    }
    
    func items(_ type: FilterType) -> [FilterItem] {
        switch type {
        case .local:
            let list: [FilterItem] = [.init(id: 0, title: local)]
            return list
        case .category:
            let list: [FilterItem] = categories.map {
                .init(id: $0.id, title: $0.title)
            }
            return list
        case .location:
            let list: [FilterItem] = locations.map {
                .init(id: $0.id, title: $0.regionName)
            }
            return list
        case .age:
            let list: [FilterItem] = ages.map {
                .init(id: 0, title: $0)
            }
            return list
        }
    }
}

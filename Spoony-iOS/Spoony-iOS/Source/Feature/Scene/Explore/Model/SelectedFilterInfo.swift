//
//  SelectedFilterInfo.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/27/25.
//

import Foundation

struct FilterItem: Identifiable, Equatable {
    let id: Int
    let title: String
}

struct SelectedFilterInfo: Equatable {
    var selectedLocal: [FilterItem] = []
    var selectedCategories: [FilterItem] = []
    var selectedLocations: [FilterItem] = []
    var selectedAges: [FilterItem] = []
    
    func items(_ type: FilterType) -> [FilterItem] {
        switch type {
        case .local:
            return selectedLocal.sorted { $0.title < $1.title }
        case .category:
            return selectedCategories.sorted { $0.id < $1.id }
        case .location:
            return selectedLocations.sorted { $0.id < $1.id }
        case .age:
            return selectedAges.sorted { $0.title < $1.title }
        }
    }
}

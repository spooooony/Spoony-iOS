//
//  SelectedFilterInfo.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/27/25.
//

import Foundation

struct SelectedFilterInfo: Equatable {
    var selectedLocal: [String] = []
    var selectedCategories: [String] = []
    var selectedLocations: [String] = []
    var selectedAges: [String] = []
    
    func items(_ type: FilterType) -> [String] {
        switch type {
        case .local:
            return selectedLocal
        case .category:
            return selectedCategories
        case .location:
            return selectedLocations
        case .age:
            return selectedAges
        }
    }
}

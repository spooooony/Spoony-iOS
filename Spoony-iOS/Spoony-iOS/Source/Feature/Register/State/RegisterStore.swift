//
//  RegisterStore.swift
//  Spoony-iOS
//
//  Created by 최안용 on 1/16/25.
//

import Foundation

final class RegisterStore: ObservableObject {
    @Published var step: RegisterStep = .start
    @Published var disableFirstButton: Bool = true
    @Published var text: String = ""
    @Published var isSelected: Bool = false
    @Published var categorys: [CategoryChip] = CategoryChip.sample()
    @Published var recommendMenu: [String] = [""] {
        didSet {
            firstButtonInvalid()
        }
    }
    @Published var selectedCategory: [CategoryChip] = [] {
        didSet {
            firstButtonInvalid()
        }
    }
    @Published var searchPlaces: [PlaceInfo] = PlaceInfo.sample()
    @Published var selectedPlace: PlaceInfo? {
        didSet {
            firstButtonInvalid()
        }
    }
    
    func firstButtonInvalid() {
        let isRecommendMenuInvalid = recommendMenu.contains { $0.isEmpty }
        
        let isSelectedCategoryInvalid = selectedCategory.isEmpty

        let isSelectedPlaceInvalid = selectedPlace == nil

        disableFirstButton = isRecommendMenuInvalid || isSelectedCategoryInvalid || isSelectedPlaceInvalid
    }
}

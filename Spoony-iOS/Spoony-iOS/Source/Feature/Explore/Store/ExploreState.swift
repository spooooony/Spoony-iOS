//
//  ExploreState.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/23/25.
//

import Foundation

struct ExploreState {
    var exploreList: [FeedEntity] = []
    var spoonCount: Int = 0
    
    //TODO: 현재 위치 받아와서 바꾸기
    var selectedLocation: SeoulType = .gangnam
    var tempLocation: SeoulType?
    
    var selectedFilter: FilterType = .latest
    
    var navigationTitle: String = ""
    
    var categoryList: [CategoryChip] = []
    var selectedCategory: CategoryChip?
    
    var isPresentedLocation: Bool = false
    var isPresentedFilter: Bool = false
    
    var isSelectLocationButtonDisabled: Bool = true
}

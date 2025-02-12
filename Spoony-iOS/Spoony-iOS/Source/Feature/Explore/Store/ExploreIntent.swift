//
//  ExploreIntent.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/23/25.
//

import Foundation

enum ExploreIntent {
    case onAppear
    
    // Location Bottom Sheet
    case navigationLocationTapped
    case locationTapped(SeoulType)
    case selectLocationTapped
    case closeLocationTapped
    case isPresentedLocationChanged(Bool)
    
    // Filter Bottom Sheet
    case filterButtontapped
    case filterTapped(FilterType)
    case closeFilterTapped
    case isPresentedFilterChanged(Bool)
    
    // Main
    case categoryTapped(CategoryChip)

}

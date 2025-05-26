//
//  FilterType.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/27/25.
//

import Foundation

enum FilterType: CaseIterable {
    case local
    case category
    case location
    case age
    
    var title: String {
        switch self {
        case .local:
            "속성"
        case .category:
            "카테고리"
        case .location:
            "지역"
        case .age:
            "연령대"
        }
    }
}

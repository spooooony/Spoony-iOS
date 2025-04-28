//
//  FilterButtonType.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/26/25.
//

import Foundation

enum FilterButtonType: Int, CaseIterable {
    case filter = -1
    case local = 0
    case category = 1
    case location = 2
    case age = 3
    
    var title: String {
        switch self {
        case .filter:
            "필터"
        case .local:
            "로컬 리뷰"
        case .category:
            "카테고리"
        case .location:
            "지역"
        case .age:
            "연령대"
        }
    }
    
    var isLeadingIcon: Bool {
        switch self {
        case .filter:
            true
        default:
            false
        }
    }
    
    var isTrailingIcon: Bool {
        switch self {
        case .filter, .local:
            false
        default:
            true
        }
    }
}

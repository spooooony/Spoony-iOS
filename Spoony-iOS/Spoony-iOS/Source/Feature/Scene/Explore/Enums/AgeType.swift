//
//  AgeType.swift
//  Spoony-iOS
//
//  Created by 최주리 on 5/11/25.
//

import Foundation

enum AgeType: CaseIterable {
    case ten
    case twenty
    case thirty
    case fourty
    
    var title: String {
        switch self {
        case .ten:
            "10대"
        case .twenty:
            "20대"
        case .thirty:
            "30대"
        case .fourty:
            "40대+"
        }
    }
    
    var key: String {
        switch self {
        case .ten:
            "AGE_10S"
        case .twenty:
            "AGE_20S"
        case .thirty:
            "AGE_30S"
        case .fourty:
            "AGE_ETC"
        }
    }
    
    static func toType(from title: String) -> AgeType? {
        return AgeType.allCases.first { $0.title == title }
    }
}

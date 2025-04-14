//
//  DateType.swift
//  Spoony-iOS
//
//  Created by 최안용 on 4/13/25.
//

import Foundation

enum DateType: Int, CaseIterable {
    case year = 0
    case month = 1
    case day = 2
    
    var title: String {
        switch self {
        case .year:
            "년"
        case .month:
            "월"
        case .day:
            "일"
        }
    }
    
    var placeHolder: String {
        switch self {
        case .year:
            "2000"
        case .month:
            "01"
        case .day:
            "01"
        }
    }
    
    var width: CGFloat {
        switch self {
        case .year:
            87.adjusted
        case .month, .day:
            65.adjusted
        }
    }
}

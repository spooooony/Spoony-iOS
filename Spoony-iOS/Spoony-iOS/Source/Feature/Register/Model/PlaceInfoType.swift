//
//  PlaceInfoType.swift
//  Spoony-iOS
//
//  Created by 최안용 on 1/17/25.
//

import Foundation

enum PlaceInfoType {
    case listCell
    case selectedCell
    
    var isIcon: Bool {
        switch self {
        case .listCell:
            return false
        case .selectedCell:
            return true
        }
    }
    
    var height: CGFloat {
        switch self {
        case .listCell:
            return 63.adjustedH
        case .selectedCell:
            return 59.adjustedH
        }
    }
    
    var leadingIconSpacing: CGFloat {
        switch self {
        case .listCell:
            return 8
        case .selectedCell:
            return 4
        }
    }
    
    var trailingIconSpacing: CGFloat {
        return 8
    }
    
    var horizontalSpacing: CGFloat {
        switch self {
        case .listCell:
            return 16
        case .selectedCell:
            return 12
        }
    }
    
    var verticalSpacing: CGFloat {
        switch self {
        case .listCell:
            return 12
        case .selectedCell:
            return 10
        }
    }
}

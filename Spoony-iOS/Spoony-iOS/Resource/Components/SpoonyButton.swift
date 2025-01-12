//
//  ButtonModifier.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/12/25.
//

import SwiftUI

@frozen
public enum SpoonyButtonSize {
    case xlarge
    case large
    case medium
    case small
    case xsmall
    
    var font: Font {
        switch self {
        case .xlarge:
            return .body1b
        case .large, .medium, .small, .xsmall:
            return .body2b
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .xlarge:
            return 8
        case .large, .medium, .small, .xsmall:
            return 10
        }
    }
    
    var width: CGFloat {
        switch self {
        case .xlarge:
            return 335
        case .large:
            return 295
        case .medium:
            return 263
        case .small:
            return 216
        case .xsmall:
            return 141
        }
    }
    
    var height: CGFloat {
        switch self {
        case .xlarge, .large, .medium, .small:
            return 56
        case .xsmall:
            return 44
        }
    }
}

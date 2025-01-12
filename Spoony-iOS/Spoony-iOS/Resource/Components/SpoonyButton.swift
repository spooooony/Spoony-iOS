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

@frozen
public enum SpoonyButtonStyle {
    case primary
    case secondary
    case teritary
    
    var enabledColor: Color {
        switch self {
        case .primary:
            return .main400
        case .secondary:
            return .spoonBlack
        case .teritary:
            return .gray0
        }
    }
    
    var pressedColor: Color {
        switch self {
        case .primary:
            return .main500
        case .secondary:
            return .gray800
        case .teritary:
            return .gray100
        }
    }
    
    var disabledColor: Color {
        switch self {
        case .primary:
            return .main100
        case .secondary:
            return .gray300
        case .teritary:
            return .gray100
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .primary, .secondary:
            return .white
        case .teritary:
            return .gray600
        }
    }
}

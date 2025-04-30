//
//  ShadowModifier.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/30/25.
//

import SwiftUI

enum ShadowStyle {
    case shadow0
    case shadow300
    case shadow400
    case shadow500
}

extension ShadowStyle {
    var color: Color {
        switch self {
        case .shadow0:
                .gray0
        case .shadow300:
                .gray300
        case .shadow400:
                .gray400
        case .shadow500:
                .grayShadow
        }
    }
    
    var opacity: CGFloat {
        switch self {
        case .shadow500:
            0.3
        default:
            1
        }
    }
    
    var positionX: CGFloat {
        switch self {
        case .shadow0:
            0
        case .shadow300, .shadow400:
            1
        case .shadow500:
            -8
        }
    }
    
    var positionY: CGFloat {
        switch self {
        case .shadow0:
            2
        case .shadow300, .shadow400:
            1
        case .shadow500:
            0
        }
    }
    
    var blur: CGFloat {
        switch self {
        case .shadow0, .shadow300, .shadow400:
            16
        case .shadow500:
            10
        }
    }
}

struct ShadowModifier: ViewModifier {
    let style: ShadowStyle
    
    func body(content: Content) -> some View {
        content
            .overlay {
                content
                    .colorMultiply(style.color.opacity(style.opacity))
                    .mask(content)
                    .offset(x: style.positionX, y: style.positionY)
                    .blur(radius: style.blur)
            }
            .overlay {
                content
            }
    }
}

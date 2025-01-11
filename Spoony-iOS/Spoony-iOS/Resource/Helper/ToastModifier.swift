//
//  ToastModifier.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/10/25.
//

import Foundation
import SwiftUI

public struct Toast: Equatable {
    var style: ToastStyle
    var message: String
    var duration: Double = 3
    var width: Double = .infinity
    var yOffset: CGFloat = 638
}

public enum ToastStyle {
    case grey
}

extension ToastStyle {
    var themeColor: Color {
        switch self {
        case .grey: return .gray600
}
    }
}

struct ToastView: View {
    
    var style: ToastStyle
    var message: String
    var width = CGFloat.infinity
    var onCancelTapped: (() -> Void)
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(message)
                .font(.body2b)
                .foregroundColor(.white)
        }
        .padding()
        .frame(minWidth: 0, maxWidth: width)
        .background(style.themeColor)
        .cornerRadius(8)
    }
}

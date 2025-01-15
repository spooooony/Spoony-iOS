//
//  ButtonModifier.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/12/25.
//

import SwiftUI

/// SpoonyButton
/// - Parameters:
///   - style: 버튼 스타일
///   - size: 버튼 크기
///   - title: 버튼 Text
///   - isIcon: ICon 존재 유무
///   - disabled: 비활성화 유무
///   - action: 사용자 Action
public struct SpoonyButton: View {
    
    // MARK: - Properties
    let style: SpoonyButtonStyle
    let size: SpoonyButtonSize
    let title: String
    let isIcon: Bool
    @Binding var disabled: Bool
    var action: () -> Void
    
    private var backgroundColor: Color {
        if disabled {
            return style.disabledColor
        } else if isSelected {
            return style.pressedColor
        } else {
            return style.enabledColor
        }
    }
    
    @State private var isSelected: Bool = false
    
    // MARK: - Init
    public init(
        style: SpoonyButtonStyle,
        size: SpoonyButtonSize,
        title: String,
        isIcon: Bool = false,
        disabled: Binding<Bool>,
        action: @escaping () -> Void
    ) {
        
        self.style = style
        self.size = size
        self.title = title
        self.isIcon = isIcon
        self._disabled = disabled
        self.action = action
    }
    
    // MARK: - Body
    public var body: some View {
        Button {
            
        } label: {
            HStack(spacing: 8) {
                if isIcon {
                    if let image = style.image {
                        image
                    }
                }
                Text(title)
                    .font(size.font)
                    .foregroundStyle(style.foregroundColor)
            }
            .frame(width: size.width, height: size.height)
            .background(backgroundColor)
            .cornerRadius(size.cornerRadius)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        isSelected = true
                    }
                    .onEnded { _ in
                        isSelected = false
                        action()
                    }
            )
        }
        .disabled(disabled)
    }
}

// MARK: - SpoonyButtonSize
public enum SpoonyButtonSize {
    case xlarge
    case large
    case medium
    case small
    case xsmall
    case bottomSheet
    
    var font: Font {
        switch self {
        case .xlarge:
            return .body1b
        case .large, .medium, .small, .xsmall, .bottomSheet:
            return .body2b
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .xlarge:
            return 8
        case .large, .medium, .small, .xsmall, .bottomSheet:
            return 10
        }
    }
    
    var width: CGFloat {
        switch self {
        case .xlarge, .bottomSheet:
            return 335.adjusted
        case .large:
            return 295.adjusted
        case .medium:
            return 263.adjusted
        case .small:
            return 216.adjusted
        case .xsmall:
            return 141.adjusted
        }
    }
    
    var height: CGFloat {
        switch self {
        case .xlarge, .bottomSheet, .large, .medium, .small:
            return 56.adjustedH
        case .xsmall:
            return 44.adjustedH
        }
    }
}

// MARK: - SpoonyButtonStyle
public enum SpoonyButtonStyle {
    case primary
    case secondary
    case teritary
    case activate
    case deactivate
    
    var enabledColor: Color {
        switch self {
        case .primary:
            return .main400
        case .secondary:
            return .spoonBlack
        case .teritary, .activate:
            return .gray0
        case .deactivate:
            return .white
            
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
        case .activate:
            return .gray0
        case .deactivate:
            return .white
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
        case .activate:
            return .gray0
        case .deactivate:
            return .white
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .primary, .secondary:
            return .white
        case .teritary:
            return .gray600
        case .activate:
            return .gray900
        case .deactivate:
            return .gray400
        }
    }
    
    var image: Image? {
        switch self {
        case .primary:
            return Image(.icSpoonPrimary)
        case .secondary:
            return Image(.icSpoonSecondary)
        case .teritary, .activate, .deactivate:
            return nil
        }
    }
}

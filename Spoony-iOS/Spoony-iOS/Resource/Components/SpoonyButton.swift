//
//  ButtonModifier.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/12/25.
//

import SwiftUI

public struct SpoonyButton: View {
    
    // MARK: - Properties
    
    let state: SpoonyButtonStyle
    let size: SpoonyButtonSize
    let title: String
    @Binding var disabled: Bool
    var action: () -> Void
    
    private var backgroundColor: Color {
        if disabled {
            return state.disabledColor
        } else if isSelected {
            return state.pressedColor
        } else {
            return state.enabledColor
        }
    }
    
    @State private var isSelected: Bool = false
    
    // MARK: - Init
    
    public init(
        state: SpoonyButtonStyle,
        size: SpoonyButtonSize,
        title: String,
        disabled: Binding<Bool>,
        action: @escaping () -> Void
    ) {
        
        self.state = state
        self.size = size
        self.title = title
        self._disabled = disabled
        self.action = action
    }
    
    // MARK: - Body
    
    public var body: some View {
        Button {
            
        } label: {
            Text(title)
                .font(size.font)
                .foregroundStyle(state.foregroundColor)
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
        .disabled(disabled)
    }
}


// MARK: - SpoonyButtonSize
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

// MARK: - SpoonyButtonStyle
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

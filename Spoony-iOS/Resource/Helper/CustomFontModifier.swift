//
//  CustomFontModifier.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/22/25.
//

import SwiftUI

public struct CustomFontModifier: ViewModifier {
    let font: Font
    let lineSpacing: CGFloat = 1.45
    let letterSpacing: CGFloat = -0.02
    
    /// 행 자간을 설정해주는 modifier 입니다.
    public func body(content: Content) -> some View {
        content
            .font(font)
            .lineSpacing(lineSpacing)
            .tracking(letterSpacing)
    }
}

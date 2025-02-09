//
//  ScrollOffsetPreferenceKey.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 2/10/25.
//

import SwiftUI

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

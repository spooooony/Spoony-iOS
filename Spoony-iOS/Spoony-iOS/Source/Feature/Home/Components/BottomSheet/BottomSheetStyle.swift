//
//  BottomSheetStyle.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/12/25.
//

import SwiftUI

enum BottomSheetStyle {
    case full
    case half
    case minimal
    
    var height: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let bottomSafeArea = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        
        switch self {
        case .full:
            return screenHeight * 0.876
        case .half:
            return screenHeight * 0.5
        case .minimal:
            return screenHeight * 0.25
        }
    }
}

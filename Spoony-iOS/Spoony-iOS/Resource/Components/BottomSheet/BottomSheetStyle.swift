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
        
        switch self {
        case .full:
            return screenHeight * 0.876
        case .half:
            return (120.adjusted * 3) + 60.adjustedH + 20
        case .minimal:
            return screenHeight * 0.25
        }
    }
}

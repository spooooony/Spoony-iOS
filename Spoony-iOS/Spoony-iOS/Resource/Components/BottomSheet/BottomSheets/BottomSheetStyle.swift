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
            return screenHeight * 0.8
        case .half:
            return (140.adjusted * 2) + 60.adjustedH + 84 
        case .minimal:
            return 60.adjustedH + 84.adjustedH
        }
    }
}

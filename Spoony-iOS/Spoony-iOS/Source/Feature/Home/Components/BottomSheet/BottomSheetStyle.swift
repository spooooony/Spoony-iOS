//
//  BottomSheetStyle.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/12/25.
//

import SwiftUI

enum BottomSheetStyle {
    case full    // 네비게이션 바 아래까지
    case half    // 화면 중간까지
    case minimal // 타이틀만 보이는 경우
    
    var height: CGFloat {
        switch self {
        case .full:
            return UIScreen.main.bounds.height * 0.8
        case .half:
            return UIScreen.main.bounds.height * 0.4
        case .minimal:
            return UIScreen.main.bounds.height * 0.25
        }
    }
} 

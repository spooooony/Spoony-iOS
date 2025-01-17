import SwiftUI

enum BottomSheetStyle {
    case full    // 네비게이션 바 아래까지
    case half    // 화면 중간까지
    case minimal // 타이틀만 보이는 경우
    case button  // 이미지와 버튼만 있는 경우
    
    var height: CGFloat {
        switch self {
        case .full:
            return UIScreen.main.bounds.height * 0.9
        case .half:
            return UIScreen.main.bounds.height * 0.5
        case .minimal:
            return UIScreen.main.bounds.height * 0.3
        case .button:
            return UIScreen.main.bounds.height * 0.25
        }
    }
} 
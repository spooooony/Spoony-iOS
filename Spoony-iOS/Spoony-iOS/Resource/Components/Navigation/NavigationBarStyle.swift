//
//  NavigationBarStyle.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/12/25.
//

import SwiftUI

enum NavigationBarStyle {
    
    // 검색 관련
    case searchContent //지도에서 왼쪽에 칩 있는거
    case search(showBackButton: Bool = true) // 뒤로가기 버튼 표시 여부 추가
    case searchBar
    case settingContent
    
    // 위치 관련
    case locationTitle    // 위치 제목 + 오른쪽 X 버튼
    case locationDetail   // 탐색 리스트 - 현위치 + > + 오른쪽 칩 아이콘
    
    // 상세 화면 관련
    case detail         // < + 가운데 타이틀 사용 (신고하기)
    case detailWithChip    // < + 오른쪽 칩 (가운데 타이틀 없음)
    
    // 온보딩 관련
    case onboarding     // < + 오른쪽 건너뛰기 버튼
    
    // 백 버튼 표시 여부
    var showsBackButton: Bool {
        switch self {
        case .locationDetail, .locationTitle, .searchContent:
            return false
        case .search(let showBackButton):
            return showBackButton
        default:
            return true
        }
    }
}

//
//  NavigationBarStyle.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/12/25.
//

import SwiftUI

enum NavigationBarStyle {
    // 기본 네비게이션
    //지도뷰 에 왼쪽 타이틀 오른쪽에 X버튼 있는뷰 (검색상세로 넘어갈때)
   //case primary
    
    // 검색 관련
    case search(showBackButton: Bool = true) // 뒤로가기 버튼 표시 여부 추가
    case searchBar
    
    // 위치 관련
    case locationTitle    // 위치 제목 + 오른쪽 X 버튼
    case locationDetail   // 탐색 리스트 - 현위치 + > + 오른쪽 칩 아이콘
    
    // 상세 화면 관련
    case detail(isLiked: Bool)         // 좋아요 기능이 있는 상세
    case detailWithChip(count: Int)    // < + 오른쪽 칩 (가운데 타이틀 없음)
    
    // 백 버튼 표시 여부
    var showsBackButton: Bool {
        switch self {
        case .locationDetail, .locationTitle:
            return false
        case .search(let showBackButton):
            return showBackButton
        default:
            return true
        }
    }
}

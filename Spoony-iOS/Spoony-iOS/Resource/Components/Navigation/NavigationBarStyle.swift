//
//  NavigationBarStyle.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/12/25.
//

import SwiftUI

enum NavigationBarStyle {
    // 기본 네비게이션
    case primary
    
    // 검색 관련
    case search(showBackButton: Bool = true) // 뒤로가기 버튼 표시 여부 추가
    
    // 위치 관련
    case locationTitle    // 위치 제목만 표시
    case locationDetail   // 위치 상세 정보 표시
    
    // 상세 화면 관련
    case detail(isLiked: Bool)         // 좋아요 기능이 있는 상세
    case detailWithChip(count: Int)    // 카운트 칩이 있는 상세
    
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

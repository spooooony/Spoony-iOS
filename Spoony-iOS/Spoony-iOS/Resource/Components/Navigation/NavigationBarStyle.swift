//
//  NavigationBarStyle.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/12/25.
//

import SwiftUI

enum NavigationBarStyle {
    //기본네비
    case navTopPrimaryOneCenter(isLiked: Bool)   

    
    // 검색 관련
    case navTopSearchNormalDefault(showBackButton: Bool = true)
    
    // 위치 관련
    case navTopPrimaryOneLeft      // 위치 제목만 표시
    case navTopPrimaryTwoLeft      // 위치 상세 정보 표시
    
    // 상세 화면 관련
    case navTopPrimaryOneChip(count: Int)        // 카운트 칩이 있는 상세
    
    // 백 버튼 표시 여부
    var showsBackButton: Bool {
        switch self {
        case .navTopPrimaryTwoLeft, .navTopPrimaryOneLeft:
            return false
        case .navTopSearchNormalDefault(let showBackButton):
            return showBackButton
        default:
            return true
        }
    }
}

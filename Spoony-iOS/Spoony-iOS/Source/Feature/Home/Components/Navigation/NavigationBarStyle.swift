//
//  NavigationBarStyle.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/12/25.
//

import SwiftUI

enum NavigationBarStyle {
    case primary
    case search
    case location
    case detail(isLiked: Bool)
    case detailWithChip(count: Int)  // 오른쪽에 칩이 있는 스타일 추가
} 
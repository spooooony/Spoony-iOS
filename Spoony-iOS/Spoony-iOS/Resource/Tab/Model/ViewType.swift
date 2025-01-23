//
//  ViewType.swift
//  SpoonMe
//
//  Created by 최주리 on 1/7/25.
//

import Foundation

enum ViewType: Hashable {
    case searchView    // 검색 화면
    case locationView(title: String)  // 위치 선택 화면
    case detailView   // 상세 화면

    case report
}

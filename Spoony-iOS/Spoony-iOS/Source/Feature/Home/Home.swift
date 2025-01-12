//
//  Home.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/2/25.
//

import SwiftUI
// 사용 예시
struct Home: View {
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // 기본형 네비게이션
            CustomNavigationBar(
                style: .primary,
                title: "수저 뽑기",
                onBackTapped: { }
            )
            
            // 검색형 네비게이션
            CustomNavigationBar(
                style: .search,
                searchText: $searchText,
                onBackTapped: { },
                onSearchSubmit: { }
            )
            
            // 위치 선택형 네비게이션
            CustomNavigationBar(
                style: .location,
                title: "서울특별시 마포구",
                onBackTapped: { }
            )
            
            Spacer()
        }
    }
}

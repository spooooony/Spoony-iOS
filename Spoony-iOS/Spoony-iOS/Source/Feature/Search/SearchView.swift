//
//  SearchView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/16/25.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                style: .search(showBackButton: true),
                searchText: $searchText,
                onBackTapped: {
                    // 뒤로가기
                    navigationManager.pop(1)
                },
                onSearchSubmit: nil
            )
            
            Spacer()
        }
    }
}

#Preview {
    SearchView()
}

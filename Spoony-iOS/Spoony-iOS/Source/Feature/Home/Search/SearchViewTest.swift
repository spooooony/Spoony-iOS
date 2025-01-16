//
//  SearchViewTest.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/16/25.
//

import SwiftUI

struct SearchViewTest: View {
    @State private var searchText = ""
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CustomNavigationBar(
                    style: .searchBar,
                    searchText: $searchText,
                    onBackTapped: {},
                    onSearchSubmit: {
                        print("Search submitted: \(searchText)")
                    }
                )
                
                Spacer()
            }
            VStack(spacing: 8) {
                Rectangle()
                    .fill(Color(.gray200))
                    .frame(width: 200, height: 200)
                    .padding(.bottom, 12)
                
                Text("구체적인 장소를 검색해 보세요")
                    .font(.system(size: 16))
                    .foregroundColor(Color(.gray600))
            }
            .offset(y: -100)
        }
    }
}

#Preview {
    SearchViewTest()
}

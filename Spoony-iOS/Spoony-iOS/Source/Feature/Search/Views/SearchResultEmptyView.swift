//
//  SearchResultEmptyView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/17/25.
//

import SwiftUI

struct SearchResultEmptyView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 72.adjusted)
            
            VStack(spacing: 8) {
                Image(.imageEmptySearchResult)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 20)
                    .frame(width: 220.adjusted, height: 100.adjustedH)
                
                Text("검색 결과가 없습니다")
                    .customFont(.body2sb)
                    .foregroundColor(.spoonBlack)
                    .padding(.top, 24)
                
                Text("정확한 지면(구/동),\n지하철역을 입력해보세요 ")
                    .customFont(.body2m)
                    .foregroundColor(.gray500)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
    }
}

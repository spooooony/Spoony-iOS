//
//  EmptyStateView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/17/25.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 72.adjustedH)
            
            VStack(spacing: 8) {
                Image(.imageEmptySearch)
                    .padding(.bottom, 12)
                
                Text("구체적인 장소를 검색해 보세요")
                    .customFont(.body2m)
                    .foregroundStyle(.gray500)
            }
            
            Spacer()
        }
    }
}

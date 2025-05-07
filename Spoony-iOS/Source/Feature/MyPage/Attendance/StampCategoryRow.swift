//
//  StampCategoryRow.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/17/25.
//

import SwiftUI

struct StampCategoryRow: View {
    let title: String
    let count: String
    
    var body: some View {
        HStack(spacing: 2) {
            Text(title)
                .customFont(.body1m)
                .foregroundColor(.gray700)
                .frame(width: 130.adjusted, height: 47.adjustedH)
                .background(Color.gray100)
            
            Text(count)
                .customFont(.body1m)
                .foregroundColor(.gray700)
                .frame(width: 203.adjusted, height: 47.adjustedH)
                .background(Color.gray0)
        }
        .padding(.horizontal, 20)
    }
}

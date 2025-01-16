//
//  SearchResultRow.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/16/25.
//

import SwiftUI

struct SearchResultRow: View {
    let result: SearchResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(.icPinGray600)
                Text(result.title)
                    .font(.body1b)
                    .foregroundStyle(.black)
            }
            
            Text(result.address)
                .font(.body2b)
                .foregroundStyle(.gray600)
                .padding(.leading, 30)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    SearchResultRow(result: SearchResult(title: "테스트 장소", address: "테스트 주소"))
}

//
//  RecentSearchesView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/17/25.
//

import SwiftUI

struct RecentSearchesView: View {
    let recentSearches: [String]
    let onRemoveSearch: (String) -> Void
    let onClearAll: () -> Void
    let onSelectSearch: (String) -> Void 
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("최근 검색")
                    .customFont(.body2b)
                
                Spacer()
                Button("전체삭제", action: onClearAll)
                    .customFont(.caption1m)
                    .foregroundStyle(.gray500)
                    .frame(width: 57.adjusted, height: 24.adjustedH)
                    .contentShape(Rectangle())
                    .padding(.horizontal, 2)
                    .padding(.vertical, 8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            VStack(alignment: .leading, spacing: 0) {
                ForEach(recentSearches, id: \.self) { search in
                    Button(action: { onSelectSearch(search) }) {
                        HStack {
                            Text(search)
                                .customFont(.body1b)
                                .foregroundColor(.gray700)
                            Spacer()
                            Button(action: { onRemoveSearch(search) }) {
                                Image(.icCloseGray400)
                            }
                        }
                        .padding(.horizontal, 16.adjusted)
                        .padding(.vertical, 14.5.adjustedH)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if search != recentSearches.last {
                        Divider()
                            .foregroundStyle(.gray400)
                            .padding(.horizontal, 16)
                    }
                }
            }
        }
    }
}

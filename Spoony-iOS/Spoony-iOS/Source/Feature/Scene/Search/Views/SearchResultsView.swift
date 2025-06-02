//
//  SearchResultsView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/17/25.
//

import SwiftUI

struct SearchResultsView: View {
    let results: [SearchResult]
    let onSelectResult: (SearchResult) -> Void
    
    var body: some View {
        ScrollView {
            if results.isEmpty {
                SearchResultEmptyView()
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(results) { result in
                        VStack(spacing: 0) {
                            SearchResultRow(result: result) {
                                onSelectResult(result)
                            }
                            
                            if result.id != results.last?.id {
                                Divider()
                                    .foregroundStyle(.gray400)
                                    .padding(.horizontal, 16)
                            }
                        }
                    }
                }
            }
        }
    }
}

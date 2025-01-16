//
//  SearchViewTest.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/16/25.
//

import SwiftUI

struct SearchViewTest: View {
    @State private var searchText = ""
    @State private var searchResults: [SearchResult] = []
    @State private var searchState: SearchState = .empty
    @State private var recentSearches = ["홍대입구역", "성수동", "망원동"]
        
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CustomNavigationBar(
                    style: .searchBar,
                    searchText: $searchText,
                    onBackTapped: {},
                    onSearchSubmit: handleSearch
                )
                
                switch searchState {
                case .empty:
                    if recentSearches.isEmpty {
                        emptyStateView
                    } else {
                        recentSearchesView
                    }
                case .typing:
                    recentSearchesView
                case .searched:
                    List {
                        ForEach(getFilteredResults(), id: \.id) { result in
                            SearchResultRow(result: result)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                
                Spacer()
            }
        }
        .onChange(of: searchText) { newValue, _ in
            if newValue.isEmpty {
                searchState = .empty
            } else if searchState != .searched {
                searchState = .typing
            }
        }
    }
    
    private func handleSearch() {
        guard !searchText.isEmpty else { return }
        searchState = .searched
        updateSearchResults()
    }
    
    // TODO: 추후 로티로 수정
    private var emptyStateView: some View {
        VStack {
            Spacer()
            VStack(spacing: 8) {
                Rectangle()
                    .fill(.gray200)
                    .frame(width: 200.adjusted, height: 200.adjustedH)
                    .padding(.bottom, 12)
                
                Text("구체적인 장소를 검색해 보세요")
                    .font(.body2m)
                    .foregroundColor(.gray600)
            }
            Spacer()
                .frame(height: 100.adjustedH)
        }
    }
    
    private var recentSearchesView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("최근 검색")
                    .font(.body2b)
                Spacer()
                Button("전체삭제") {
                    recentSearches.removeAll()
                    searchState = .empty
                }
                .font(.caption1m)
                .foregroundColor(.gray600)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            VStack(alignment: .leading, spacing: 0) {
                ForEach(recentSearches, id: \.self) { search in
                    HStack {
                        Text(search)
                            .font(.body1b)
                        Spacer()
                        Button(action: {
                            if let index = recentSearches.firstIndex(of: search) {
                                recentSearches.remove(at: index)
                            }
                        }) {
                            Image(.icCloseGray400)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
        }
    }
    
    private func updateSearchResults() {
        switch searchText.isEmpty {
        case false:
            searchResults = [
                SearchResult(title: "\(searchText)", address: "\(searchText)"),
                SearchResult(title: "\(searchText)", address: "\(searchText)"),
                SearchResult(title: "\(searchText)", address: "\(searchText)")
            ]
            
            if !recentSearches.contains(searchText) {
                recentSearches.insert(searchText, at: 0)
            if recentSearches.count > 5 {
                    recentSearches.removeLast()
                }
            }
            
        case true:
            searchResults.removeAll()
        }
    }
    
    private func getFilteredResults() -> [SearchResult] {
        return searchResults
    }
}

#Preview {
    SearchViewTest()
}

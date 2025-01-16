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
    
    enum SearchState {
        case empty
        case typing
        case searched
    }
    
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
                    emptyStateView
                case .typing:
                    recentSearchesView
                case .searched:
                    // 검색 결과 리스트
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
        .onChange(of: searchText) { newValue in
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
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            VStack(spacing: 8) {
                Rectangle()
                    .fill(Color(.gray200))
                    .frame(width: 200, height: 200)
                    .padding(.bottom, 12)
                
                Text("구체적인 장소를 검색해 보세요")
                    .font(.system(size: 16))
                    .foregroundColor(Color(.gray600))
            }
            Spacer()
                .frame(height: 100)
        }
    }
    
    private var recentSearchesView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("최근 검색")
                    .font(.system(size: 16, weight: .medium))
                Spacer()
                Button("전체삭제") {
                    recentSearches.removeAll()
                }
                .font(.system(size: 14))
                .foregroundColor(Color(.gray600))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            VStack(alignment: .leading, spacing: 0) {
                ForEach(recentSearches, id: \.self) { search in
                    HStack {
                        Text(search)
                            .font(.system(size: 16))
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
        if !searchText.isEmpty {
            searchResults = [
                SearchResult(title: "\(searchText)구역", address: "서울 마포구 양화로 160 \(searchText)구역"),
                SearchResult(title: "\(searchText)동", address: "서울 마포구 양화로 160 \(searchText)구역"),
                SearchResult(title: "\(searchText)구", address: "서울 마포구 양화로 160 \(searchText)구역")
            ]
            
            if !recentSearches.contains(searchText) {
                recentSearches.insert(searchText, at: 0)
                if recentSearches.count > 5 {
                    recentSearches.removeLast()
                }
            }
        } else {
            searchResults.removeAll()
        }
    }
    
    private func getFilteredResults() -> [SearchResult] {
        return searchResults
    }
}

struct SearchResult: Identifiable {
    let id = UUID()
    let title: String
    let address: String
}

struct SearchResultRow: View {
    let result: SearchResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Image(.icPinGray600)
                Text(result.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
            }
            
            Text(result.address)
                .font(.system(size: 14))
                .foregroundColor(Color(.gray600))
                .padding(.leading, 28)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    SearchViewTest()
}

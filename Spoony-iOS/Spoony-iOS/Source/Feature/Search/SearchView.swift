//
//  SearchView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/16/25.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var searchText = ""
    @State private var searchResults: [SearchResult] = []
    @State private var searchState: SearchState = .empty
    @State private var recentSearches: [String] = UserManager.shared.recentSearches ?? []
    private let recentSearchesKey = "RecentSearches"
    private let locationService: SearchServiceType = SearchService()

    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CustomNavigationBar(
                    style: .search(showBackButton: true),
                    searchText: $searchText,
                    onBackTapped: {
                        navigationManager.pop(1)
                    },
                    tappedAction: {
                        handleSearch()
                    }
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
                    searchResultListView
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onChange(of: searchText) { newValue, _ in
            if newValue.isEmpty {
                searchState = .empty
            } else if searchState != .searched {
                searchState = .typing
            }
        }
        .onAppear {
            searchText = ""
            searchState = .empty
            searchResults.removeAll()
        }
    }
    
    private func handleSearch() {
        guard !searchText.isEmpty else { return }
        searchState = .searched
        updateSearchResults()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 72)
                
            VStack(spacing: 8) {
                Image(.imageEmptySearch)
                    .padding(.bottom, 12)
                
                Text("구체적인 장소를 검색해 보세요")
                    .font(.body2m)
                    .foregroundColor(.gray600)
            }
            
            Spacer()
        }
    }
    
    private var recentSearchesView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("최근 검색")
                    .font(.body2b)
                Spacer()
                Button("전체삭제") {
                    recentSearches.removeAll()
                    saveRecentSearches()
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
                                    saveRecentSearches()
                                }
                            }) {
                                Image(.icCloseGray400)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        
                        if search != recentSearches.last {
                            Divider()
                                .foregroundStyle(.gray400)
                                .padding(.horizontal, 16)
                        }
                    }
                }
            
        }
    }
    
    private var searchResultListView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(getFilteredResults(), id: \.id) { result in
                    VStack(spacing: 0) {
                        SearchResultRow(result: result) {
                            navigationManager.currentLocation = result.title
                            navigationManager.pop(1)
                        }
                        
                        if result.id != getFilteredResults().last?.id {
                            Divider()
                                .foregroundStyle(.gray400)
                                .padding(.horizontal, 16)
                        }
                    }
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
                if recentSearches.count > 6 {
                    recentSearches.removeLast()
                }
                saveRecentSearches()
            }
            
        case true:
            searchResults.removeAll()
        }
    }
    
    private func saveRecentSearches() {
        UserManager.shared.recentSearches = recentSearches
    }
    
    private func getFilteredResults() -> [SearchResult] {
        return searchResults
    }
}

#Preview {
    SearchView()
}

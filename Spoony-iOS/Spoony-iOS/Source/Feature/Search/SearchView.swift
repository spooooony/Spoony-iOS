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
    private let searchService = SearchService()
    
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
                    .customFont(.body2m)
                    .foregroundStyle(.gray500)
            }
            
            Spacer()
        }
    }
    
    private var recentSearchesView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("최근 검색")
                    .customFont(.body2b)
                
                Spacer()
                Button("전체삭제") {
                    recentSearches.removeAll()
                    saveRecentSearches()
                    searchState = .empty
                }
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
                    HStack {
                        Text(search)
                            .customFont(.body1b)
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
            if searchResults.isEmpty {
                searchResultEmptyView
            } else {
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
    }
    
    private var searchResultEmptyView: some View {
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
    
    private func updateSearchResults() {
        guard !searchText.isEmpty else {
            searchResults.removeAll()
            return
        }
        
        Task {
            do {
                let response = try await searchService.searchLocation(query: searchText)
                let results = response.locationResponseList.map { location in
                    SearchResult(
                        title: location.locationName,
                        address: location.locationAddress ?? ""
                    )
                }
                
                await MainActor.run {
                    searchResults = results
                    
                    if !recentSearches.contains(searchText) {
                        recentSearches.insert(searchText, at: 0)
                        if recentSearches.count > 6 {
                            recentSearches.removeLast()
                        }
                        saveRecentSearches()
                    }
                }
            } catch let error as SearchError {
                print("Search error: \(error.errorDescription)")
                await MainActor.run {
                    searchResults.removeAll()
                }
            } catch {
                print("Unexpected error: \(error)")
                await MainActor.run {
                    searchResults.removeAll()
                }
            }
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

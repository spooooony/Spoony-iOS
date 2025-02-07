//
//  SearchView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/16/25.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @StateObject private var store: SearchStore
    @FocusState private var isSearchFocused: Bool
    
    init() {
        _store = StateObject(wrappedValue: SearchStore(navigationManager: NavigationManager()))
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CustomNavigationBar(
                    style: .search(showBackButton: true),
                    searchText: Binding(
                        get: { store.model.searchText },
                        set: { store.dispatch(.updateSearchText($0)) }
                    ),
                    onBackTapped: {
                        store.dispatch(.clearSearch)
                        navigationManager.pop(1)
                    },
                    tappedAction: {
                        store.dispatch(.search)
                    },
                    onClearTapped: {
                        store.dispatch(.clearSearch)
                    }
                )
                .focused($isSearchFocused)
                
                contentView
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            store.updateNavigationManager(navigationManager)
            if store.model.isFirstAppear {
                isSearchFocused = true
                store.dispatch(.setFirstAppear(false))
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch store.state {
        case .empty:
            if store.model.recentSearches.isEmpty {
                EmptyStateView()
            } else {
                RecentSearchesView(
                    recentSearches: store.model.recentSearches,
                    onRemoveSearch: { search in
                        store.dispatch(.removeRecentSearch(search))
                    },
                    onClearAll: {
                        store.dispatch(.clearAllRecentSearches)
                    }
                )
            }
        case .typing:
            Color.white
        case .loading:
            ProgressView()
        case .success(let results):
            SearchResultsView(
                results: results,
                onSelectResult: { result in
                    store.dispatch(.selectLocation(result))
                }
            )
        case .error:
            SearchResultEmptyView()
        }
    }
}

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

struct RecentSearchesView: View {
    let recentSearches: [String]
    let onRemoveSearch: (String) -> Void
    let onClearAll: () -> Void
    
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

//
//  SearchView.swift
//  Spoony-iOS
//
//  Created on 4/17/25.
//

import SwiftUI
import ComposableArchitecture

struct SearchView: View {
    @Bindable private var store: StoreOf<SearchFeature>
    @FocusState private var isSearchFocused: Bool
    
    init(store: StoreOf<SearchFeature>) {
        self.store = store
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CustomNavigationBar(
                    style: .search(showBackButton: true),
                    searchText: $store.searchText.sending(\.updateSearchText),
                    onBackTapped: {
                        store.send(.clearSearch)
                        store.send(.routeToPreviousScreen)
                    },
                    tappedAction: {
                        store.send(.search)
                    },
                    onClearTapped: {
                        store.send(.clearSearch)
                    }
                )
                .focused($isSearchFocused)
                
                contentView
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if store.isFirstAppear {
                isSearchFocused = true
                store.send(.setFirstAppear(false))
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch store.searchState {
        case .empty:
            if store.recentSearches.isEmpty {
                EmptyStateView()
            } else {
                RecentSearchesView(
                    recentSearches: store.recentSearches,
                    onRemoveSearch: { search in
                        store.send(.removeRecentSearch(search))
                    },
                    onClearAll: {
                        store.send(.clearAllRecentSearches)
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
                    store.send(.selectLocation(result))
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

#Preview {
    SearchView(
        store: Store(initialState: .initialState) {
            SearchFeature()
        }
    )
}

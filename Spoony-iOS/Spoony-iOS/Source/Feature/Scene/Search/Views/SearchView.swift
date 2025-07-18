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
                        store.send(.goBack)
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
            store.send(.loadRecentSearches)
            
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
                    },
                    onSelectSearch: { search in
                        store.send(.selectRecentSearch(search))
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

#Preview {
    SearchView(
        store: Store(initialState: .initialState) {
            SearchFeature()
        }
    )
}

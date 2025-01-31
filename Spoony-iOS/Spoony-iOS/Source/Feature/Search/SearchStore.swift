//
//  SearchStore.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/24/25.
//

import SwiftUI

@MainActor
final class SearchStore: ObservableObject {
    @Published private(set) var state: SearchState = .empty
    @Published private(set) var model: SearchModel
    
    private var navigationManager: NavigationManager
    private let searchService = SearchService()
    
    init(navigationManager: NavigationManager) {
        self.navigationManager = navigationManager
        self.model = SearchModel()
    }
    
    func dispatch(_ intent: SearchIntent) {
        switch intent {
        case .updateSearchText(let newText):
            handleSearchTextUpdate(newText)
        case .search:
            handleSearch()
        case .clearSearch:
            handleClearSearch()
        case .removeRecentSearch(let search):
            handleRemoveRecentSearch(search)
        case .clearAllRecentSearches:
            handleClearAllRecentSearches()
        case .selectLocation(let result):
            handleLocationSelection(result)
        case .setFirstAppear(let isFirst):
            model.isFirstAppear = isFirst
        }
    }
    
    private func handleSearchTextUpdate(_ newText: String) {
        model.searchText = newText
        let normalizedText = newText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if normalizedText.isEmpty {
            state = .empty
        } else {
            state = .typing(searchText: normalizedText)
        }
    }
    
    private func handleSearch() {
        guard !model.searchText.isEmpty else { return }
        
        let normalizedSearchText = model.searchText.components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        
        state = .loading
        updateSearchResults(with: normalizedSearchText)
    }
    
    private func handleClearSearch() {
        model.searchText = ""
        state = .empty
    }
    
    private func handleRemoveRecentSearch(_ search: String) {
        if let index = model.recentSearches.firstIndex(of: search) {
            model.recentSearches.remove(at: index)
            saveRecentSearches()
        }
    }
    
    private func handleClearAllRecentSearches() {
        model.recentSearches.removeAll()
        saveRecentSearches()
    }
    
    private func handleLocationSelection(_ result: SearchResult) {
        state = .loading
        
        navigationManager.navigateToSearchLocation(
            locationId: result.locationId,
            locationTitle: result.title
        )
        
        state = .empty
    }
    
    private func updateSearchResults(with query: String) {
        guard !query.isEmpty else {
            state = .empty
            return
        }
        
        Task {
            do {
                let response = try await searchService.searchLocation(query: query)
                let results = response.locationResponseList.map { location in
                    SearchResult(
                        title: location.locationName,
                        locationId: location.locationId,
                        address: location.locationAddress ?? ""
                    )
                }
                
                await MainActor.run {
                    if !results.isEmpty {
                        state = .success(results: results)
                        
                        if !model.recentSearches.contains(query) {
                            model.recentSearches.insert(query, at: 0)
                            if model.recentSearches.count > 6 {
                                model.recentSearches.removeLast()
                            }
                            saveRecentSearches()
                        }
                    } else {
                        state = .error(message: "검색 결과가 없습니다")
                    }
                }
            } catch {
                print("Search error:", error)
                state = .error(message: "검색 중 오류가 발생했습니다")
            }
        }
    }
    
    func updateNavigationManager(_ manager: NavigationManager) {
        self.navigationManager = manager
    }
    
    private func saveRecentSearches() {
        UserManager.shared.recentSearches = model.recentSearches
    }
}

//
//  SearchFeature.swift
//  Spoony-iOS
//
//  Created on 4/17/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SearchFeature {
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
        
        var searchText: String = ""
        var recentSearches: [String] = UserManager.shared.recentSearches ?? []
        var isFirstAppear: Bool = true
        var isSearching: Bool = false
        var searchResults: [SearchResult] = []
        var errorMessage: String?
        
        var searchState: SearchState {
            if isSearching {
                return .loading
            }
            if let error = errorMessage {
                return .error(message: error)
            }
            if !searchResults.isEmpty {
                return .success(results: searchResults)
            }
            if !searchText.isEmpty {
                return .typing(searchText: searchText)
            }
            return .empty
        }
    }
    
    enum Action: Equatable {
        case updateSearchText(String)
        case search
        case clearSearch
        case removeRecentSearch(String)
        case clearAllRecentSearches
        case selectLocation(SearchResult)
        case setFirstAppear(Bool)
        case searchCompletedSuccess([SearchResult])
        case searchCompletedFailure(String)
        case routeToPreviousScreen
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .updateSearchText(newText):
                state.searchText = newText
                if newText.isEmpty {
                    state.searchResults = []
                    state.errorMessage = nil
                }
                return .none
                
            case .search:
                guard !state.searchText.isEmpty else { return .none }
                let normalizedSearchText = state.searchText.components(separatedBy: .whitespaces)
                    .filter { !$0.isEmpty }
                    .joined(separator: " ")
                
                state.isSearching = true
                
                return .run { [query = normalizedSearchText] send in
                    do {
                        let service = SearchService()
                        let response = try await service.searchLocation(query: query)
                        let results = response.locationResponseList.map { location in
                            SearchResult(
                                title: location.locationName,
                                locationId: location.locationId,
                                address: location.locationAddress ?? ""
                            )
                        }
                        await send(.searchCompletedSuccess(results))
                    } catch {
                        await send(.searchCompletedFailure(error.localizedDescription))
                    }
                }
                
            case .clearSearch:
                state.searchText = ""
                state.searchResults = []
                state.errorMessage = nil
                return .none
                
            case let .removeRecentSearch(search):
                if let index = state.recentSearches.firstIndex(of: search) {
                    state.recentSearches.remove(at: index)
                    let searches = state.recentSearches  
                    return .run { _ in
                        UserManager.shared.recentSearches = searches
                    }
                }
                return .none
                
            case .clearAllRecentSearches:
                state.recentSearches.removeAll()
                return .run { _ in
                    UserManager.shared.recentSearches = []
                }
                
            case let .selectLocation(result):
                state.isSearching = false
                   return .none
                
            case let .searchCompletedSuccess(results):
                state.isSearching = false
                state.searchResults = results
                state.errorMessage = nil
                
                if !results.isEmpty && !state.searchText.isEmpty {
                    if !state.recentSearches.contains(state.searchText) {
                        state.recentSearches.insert(state.searchText, at: 0)
                        if state.recentSearches.count > 6 {
                            state.recentSearches.removeLast()
                        }
                        
                        _ = state.recentSearches
                        return .run { [searches = state.recentSearches] _ in
                            UserManager.shared.recentSearches = searches
                        }
                    }
                } else if results.isEmpty {
                    state.errorMessage = "검색 결과가 없습니다"
                }
                
                return .none
                
            case let .searchCompletedFailure(errorMessage):
                state.isSearching = false
                state.searchResults = []
                state.errorMessage = "검색 중 오류가 발생했습니다"
                print("Search error:", errorMessage)
                return .none
                
            case .routeToPreviousScreen:
                return .none
                
            case let .setFirstAppear(isFirst):
                state.isFirstAppear = isFirst
                return .none
                
            }
        }
    }
}

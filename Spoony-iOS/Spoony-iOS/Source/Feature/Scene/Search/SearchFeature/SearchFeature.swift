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
        case selectRecentSearch(String)
        case setFirstAppear(Bool)
        case searchCompletedSuccess([SearchResult])
        case searchCompletedFailure(String)
        case updateRecentSearches([String])
        case routeToPreviousScreen
        case goBack
        case loadRecentSearches
        case routeToSearchLocation(SearchResult)
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
                
            case .loadRecentSearches:
                state.recentSearches = UserManager.shared.recentSearches ?? []
                return .none
                
            case .search:
                guard !state.searchText.isEmpty else { return .none }
                
                let originalSearchText = state.searchText
                let normalizedSearchText = state.searchText.components(separatedBy: .whitespaces)
                    .filter { !$0.isEmpty }
                    .joined(separator: "")
                
                state.isSearching = true
                
                UserManager.shared.setSearches(.map, originalSearchText)
                state.recentSearches = UserManager.shared.recentSearches ?? []
                
                return .run { [query = normalizedSearchText] send in
                    do {
                        let service = SearchService()
                        let response = try await service.searchLocation(query: query)
                        let results = response.locationResponseList.map { location in
                            SearchResult(
                                title: location.locationName,
                                locationId: location.locationId,
                                address: location.locationAddress ?? "",
                                latitude: location.latitude,
                                longitude: location.longitude
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
                
            case let .selectLocation(result):
                state.isSearching = false
                return .send(.routeToSearchLocation(result))
            
            case .routeToSearchLocation:
                return .none

            case let .selectRecentSearch(searchText):
                state.searchText = searchText
                return .send(.search)
                
            case let .searchCompletedSuccess(results):
                state.isSearching = false
                state.searchResults = results
                state.errorMessage = nil
                
                if results.isEmpty {
                    state.errorMessage = "검색 결과가 없습니다"
                }
                
                return .none
                                
            case let .removeRecentSearch(search):
                return .run { send in
                    UserManager.shared.deleteRecent(.map, search)
                    let updatedSearches = UserManager.shared.recentSearches ?? []
                    await send(.updateRecentSearches(updatedSearches))
                }
                
            case .clearAllRecentSearches:
                return .run { send in
                    UserManager.shared.recentSearches = []
                    await send(.updateRecentSearches([]))
                }
                
            case let .searchCompletedFailure(errorMessage):
                state.isSearching = false
                state.searchResults = []
                state.errorMessage = "검색 중 오류가 발생했습니다"
                print("Search error:", errorMessage)
                return .none
                
            case let .updateRecentSearches(searches):
                state.recentSearches = searches
                return .none
                
            case .routeToPreviousScreen:
                return .none
                
            case let .setFirstAppear(isFirst):
                state.isFirstAppear = isFirst
                return .none
                
            case .goBack:
                state.searchText = ""
                state.searchResults = []
                state.errorMessage = nil
                return .send(.routeToPreviousScreen)
                
            }
        }
    }
}

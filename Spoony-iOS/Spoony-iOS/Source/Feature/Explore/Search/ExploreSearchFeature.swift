//
//  ExploreSearchFeature.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/17/25.
//

import Foundation

import ComposableArchitecture

@Reducer
struct ExploreSearchFeature {
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
        
        var viewType: ExploreSearchViewType = .user
        var searchState: ExploreSearchState = .beforeSearch
        var searchText: String = ""
        var userResult: [SimpleUser] = []
        var reviewResult: [FeedEntity] = []
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case onSubmit
        case changeViewType(ExploreSearchViewType)
        
        case updateSearchStateFromRecentSearches
        case updateSearchStateFromSearchResult(reviewList: [FeedEntity]?, userList: [SimpleUser]?)
        
        case setRecentSearchList
        case allDeleteButtonTapped
        case recentDeleteButtonTapped(String)
        case searchByRecentSearch(String)
        
        // MARK: - Navigation
        case routeToExploreScreen
    }
    
    @Dependency(\.exploreService) var exploreService: ExploreProtocol
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.updateSearchStateFromRecentSearches)
            case .onSubmit:
                return .send(.setRecentSearchList)
            case .changeViewType(let type):
                state.viewType = type
                if state.searchState != .searching {
                    return .send(.updateSearchStateFromRecentSearches)
                }
                return .none
            case .updateSearchStateFromRecentSearches:
                if state.viewType.recentSearches.isEmpty {
                    state.searchState = .beforeSearch
                } else {
                    state.searchState = .recentSearch
                }
                return .none
            case .updateSearchStateFromSearchResult(let reviewList, let userList):
                switch state.viewType {
                case .user:
                    guard let userList else { return .none }
                    state.userResult = userList
                    
                    if state.userResult.isEmpty {
                        state.searchState = .noResult
                    } else {
                        state.searchState = .searchResult
                    }
                case .review:
                    guard let reviewList else { return .none }
                    state.reviewResult = reviewList
                    
                    if state.reviewResult.isEmpty {
                        state.searchState = .noResult
                    } else {
                        state.searchState = .searchResult
                    }
                }
                return .none
            case .allDeleteButtonTapped:
                switch state.viewType {
                case .user:
                    return .run { send in
                        UserManager.shared.exploreUserRecentSearches = []
                        await send(.updateSearchStateFromRecentSearches)
                    }
                case .review:
                    return .run { send in
                        UserManager.shared.exploreReviewRecentSearches = []
                        await send(.updateSearchStateFromRecentSearches)
                    }
                }
            case .recentDeleteButtonTapped(let text):
                switch state.viewType {
                case .user:
                    return .run { send in
                        UserManager.shared.deleteRecent(.user, text)
                        await send(.updateSearchStateFromRecentSearches)
                    }
                case .review:
                    return .run { send in
                        UserManager.shared.deleteRecent(.review, text)
                        await send(.updateSearchStateFromRecentSearches)
                    }
                }
            case .setRecentSearchList:
                let trimmedText = state.searchText.replacingOccurrences(of: " ", with: "")
                
                if trimmedText.isEmpty {
                    return .none
                }
                
                switch state.viewType {
                case .user:
                    return .run { [searchText = state.searchText] send in
                        do {
                            UserManager.shared.setSearches(.user, searchText)
                            let list = try await exploreService.searchUser(keyword: searchText).toEntity()
                            await send(.updateSearchStateFromSearchResult(reviewList: nil, userList: list))
                        }
                    }
                case .review:
                    return .run { [searchText = state.searchText] send in
                        do {
                            UserManager.shared.setSearches(.review, searchText)
                            let list = try await exploreService.searchReview(keyword: searchText).toEntity()
                            await send(.updateSearchStateFromSearchResult(reviewList: list, userList: nil))
                        }
                    }
                }
            case .searchByRecentSearch(let text):
                state.searchText = text
                switch state.viewType {
                case .user:
                    return .run { send in
                        do {
                            UserManager.shared.setSearches(.user, text)
                            let list = try await exploreService.searchUser(keyword: text).toEntity()
                            await send(.updateSearchStateFromSearchResult(reviewList: nil, userList: list))
                        } catch {
                            
                        }
                    }
                case .review:
                    return .run { send in
                        do {
                            UserManager.shared.setSearches(.review, text)
                            let list = try await exploreService.searchReview(keyword: text).toEntity()
                            await send(.updateSearchStateFromSearchResult(reviewList: list, userList: nil))
                        } catch {
                            
                        }
                    }
                }
            case .binding(\.searchText):
                let trimmedText = state.searchText.replacingOccurrences(of: " ", with: "")
                if !trimmedText.isEmpty {
                    state.searchState = .searching
                } else {
                    return .send(.updateSearchStateFromRecentSearches)
                }
                return .none
            case .routeToExploreScreen:
                return .none
            case .binding:
                return .none
            }
        }
    }
}

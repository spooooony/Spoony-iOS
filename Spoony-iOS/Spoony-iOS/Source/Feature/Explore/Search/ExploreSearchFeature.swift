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

        var deleteReviewID: Int = -1
        
        var viewType: ExploreSearchViewType = .user
        var searchState: ExploreSearchState = .beforeSearch
        var searchText: String = ""
        var userResult: [SimpleUser] = []
        var reviewResult: [FeedEntity] = []
        
        var alertType: AlertType?
        var alert: Alert?
        var isAlertPresented: Bool = false
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
        
        case deleteMyReview(Int)
        case confirmDeleteReview
        case deleteReviewResult(Bool)
        
        // MARK: - Navigation
        case routeToPreviousScreen
        case presentAlert(AlertType, Alert)
        case routeToEditReviewScreen(Int)
        case routeToDetailScreen(FeedEntity)
        case routeToReportScreen(Int)
        case routeToUserProfileScreen(Int)
    }
    
    @Dependency(\.exploreService) var exploreService: ExploreProtocol
    @Dependency(\.myPageService) var myPageService: MypageServiceProtocol
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                if !state.userResult.isEmpty {
                    return .none
                }
                if !state.reviewResult.isEmpty {
                    return .none
                }
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
                
            case .deleteMyReview(let postId):
                state.deleteReviewID = postId
                return .send(
                    .presentAlert(
                        .normalButtonTwo,
                        Alert(
                            title: "정말로 리뷰를 삭제하시겠어요?",
                            confirmButtonTitle: "네",
                            cancelButtonTitle: "아니요",
                            imageString: nil
                        )
                    )
                )
            case .confirmDeleteReview:
                return .run { [state] send in
                    do {
                        let success = try await myPageService.deleteReview(postId: state.deleteReviewID)
                        
                        await send(.deleteReviewResult(success))
                    } catch {
                        // 에러처리
                    }
                }
            case .deleteReviewResult:
                // TODO: 성공, 실패 처리
                return .none
            case .routeToEditReviewScreen:
                return .none
            case .binding(\.searchText):
                let trimmedText = state.searchText.replacingOccurrences(of: " ", with: "")
                if !trimmedText.isEmpty {
                    state.searchState = .searching
                } else {
                    return .send(.updateSearchStateFromRecentSearches)
                }
                return .none
            case .routeToPreviousScreen:
                return .none
            case let .presentAlert(type, alert):
                state.alertType = type
                state.alert = alert
                state.isAlertPresented = true
                return .none
            case .routeToDetailScreen:
                return .none
            case .routeToReportScreen:
                return .none
            case .routeToUserProfileScreen:
                return .none
            case .binding:
                return .none
            }
        }
    }
}

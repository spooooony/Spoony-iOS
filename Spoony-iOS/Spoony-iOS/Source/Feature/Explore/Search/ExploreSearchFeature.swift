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
        var userResult: [SimpleUser] = [
            .init(id: UUID(), userName: "크리스탈에메랄드수정", regionName: "서울 마포구"),
            .init(id: UUID(), userName: "크리스탈에메랄드수22", regionName: "서울 마포구"),
            .init(id: UUID(), userName: "크리스탈에메랄드수1", regionName: "서울 마포구")
        ]
        var reviewResult: [FeedEntity] = [
            .init(
                id: UUID(),
                postId: 0,
                userName: "thingjin",
                userRegion: "서울 성북구",
                description: "이자카야인데 친구랑 가서 안주만 5개 넘게 시킴.. 명성이 자자한 고등어봉 초밥은 꼭 시키세요! 입에 넣자마자 사르르 녹아 없어지는 어쩌구 저쩌구 어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구",
                categorColorResponse: .init(
                    categoryName: "양식",
                    iconUrl: "",
                    iconTextColor: "",
                    iconBackgroundColor: ""
                ),
                zzimCount: 17,
                photoURLList: [""],
                createAt: "2025-04-14T12:21:49.524Z"
            ),
            .init(
                id: UUID(),
                postId: 0,
                userName: "thingjin",
                userRegion: "서울 성북구",
                description: "이자카야인데 친구랑 가서 안주만 5개 넘게 시킴.. 명성이 자자한 고등어봉 초밥은 꼭 시키세요! 입에 넣자마자 사르르 녹아 없어지는 어쩌구 저쩌구 어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구",
                categorColorResponse: .init(
                    categoryName: "양식",
                    iconUrl: "",
                    iconTextColor: "",
                    iconBackgroundColor: ""
                ),
                zzimCount: 17,
                photoURLList: ["", ""],
                createAt: "2025-04-14T12:21:49.524Z"
            ),
            .init(
                id: UUID(),
                postId: 0,
                userName: "thingjin",
                userRegion: "서울 성북구",
                description: "이자카야인데 친구랑 가서 안주만 5개 넘게 시킴.. 명성이 자자한 고등어봉 초밥은 꼭 시키세요! 입에 넣자마자 사르르 녹아 없어지는 어쩌구 저쩌구 어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구",
                categorColorResponse: .init(
                    categoryName: "양식",
                    iconUrl: "",
                    iconTextColor: "",
                    iconBackgroundColor: ""
                ),
                zzimCount: 17,
                photoURLList: ["", "", ""],
                createAt: "2025-04-14T12:21:49.524Z"
            )
        ]
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case onSubmit
        case changeViewType(ExploreSearchViewType)
        
        case updateSearchStateFromRecentSearches
        case updateSearchStateFromSearchResult
        
        case setRecentSearchList
        case allDeleteButtonTapped
        case recentDeleteButtonTapped(String)
        
        // MARK: - Navigation
        case routeToExploreScreen
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        // TODO: 검색 유즈케이스 기획에 더 물어보기...
        // 1. 검색 완료된 상황에서 x 버튼 누르면? 검색된 결과도 사라지나?
        // 등등... 더 있을 듯
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
            case .updateSearchStateFromSearchResult:
                switch state.viewType {
                case .user:
                    if state.userResult.isEmpty {
                        state.searchState = .noResult
                    } else {
                        state.searchState = .searchResult
                    }
                case .review:
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
                        UserManager.shared.deleteRecent("exploreUserRecentSearches", text)
                        await send(.updateSearchStateFromRecentSearches)
                    }
                case .review:
                    return .run { send in
                        UserManager.shared.deleteRecent("exploreReviewRecentSearches", text)
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
                        UserManager.shared.setSearches("exploreUserRecentSearches", searchText)
                        await send(.updateSearchStateFromSearchResult)
                    }
                case .review:
                    return .run { [searchText = state.searchText] send in
                        UserManager.shared.setSearches("exploreReviewRecentSearches", searchText)
                        await send(.updateSearchStateFromSearchResult)
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

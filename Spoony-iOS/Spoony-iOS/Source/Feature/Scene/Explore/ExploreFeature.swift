//
//  ExploreFeature.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/16/25.
//

import Foundation

import ComposableArchitecture

@Reducer
struct ExploreFeature {
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
        
        var isFilterPresented: Bool = false
        var isSortFilterPresented: Bool = false
        
        var deleteReviewID: Int = -1
        
        var viewType: ExploreViewType = .all
        var selectedFilterButton: [FilterButtonType] = []
        
        var allList: [FeedEntity] = []
        var followingList: [FeedEntity] = []
        
        var selectedFilter: SelectedFilterInfo = .init()
        
        var currentFilterTypeIndex: Int = 0
        var selectedSort: SortType = .createdAt
        
        var filterInfo: FilterInfo = .init(categories: [], locations: [])
        
        var nextCursor: Int?
        var isLast: Bool = false
        
        var isLoading: Bool = false
    
        var isAlertPresented: Bool = false
        var alertType: AlertType = .normalButtonOne
        var alert: Alert = .init(
            title: "테스트",
            confirmButtonTitle: "테스트",
            cancelButtonTitle: "테스트",
            imageString: nil
        )
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case viewOnAppear
        case changeViewType(ExploreViewType)
        case filterTapped(FilterButtonType)
        case searchButtonTapped
        case goButtonTapped
        
        case fetchFilteredFeed
        case refreshFilteredFeed
        
        case fetchFollowingFeed
        
        case setFeed([FeedEntity], Int?)
        case setFilterInfo(category: [CategoryChip], location: [Region])
        
        case deleteMyReview(Int)
        case confirmDeleteReview
        case deleteReviewResult(Bool)
        
        case error(SNError)
        
        // MARK: - Navigation
        case routeToExploreSearchScreen
        case routeToPostScreen(FeedEntity)
        case routeToReportScreen(Int)
        case routeToEditReviewScreen(Int)
        case tabSelected(TabType)
        case presentAlert(AlertType, Alert)
        case presentToast(message: String)
    }
    
    @Dependency(\.exploreService) var exploreService: ExploreProtocol
    @Dependency(\.myPageService) var myPageService: MypageServiceProtocol
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .viewOnAppear:
                state.isLoading = true
                if state.viewType == .all {
                    return .send(.refreshFilteredFeed)
                } else {
                    return .send(.fetchFollowingFeed)
                }
            case .changeViewType(let type):
                state.viewType = type
                switch type {
                case .all:
                    return .send(.refreshFilteredFeed)
                case .following:
                    return .send(.fetchFollowingFeed)
                }
            case .filterTapped(let type):
                if type.rawValue >= 0 {
                    state.currentFilterTypeIndex = type.rawValue
                } else {
                    state.currentFilterTypeIndex = 0
                }
                
                return .run { send in
                    do {
                        let categories = try await exploreService.getCategoryList().toModel()
                        let locations = try await exploreService.getRegionList().toEntity()
                        
                        await send(.setFilterInfo(category: categories, location: locations))
                    } catch {
                        await send(.error(SNError.networkFail))
                    }
                }
            case .routeToPostScreen:
                return .none
            case .searchButtonTapped:
                return .send(.routeToExploreSearchScreen)
            case .goButtonTapped:
                if state.viewType == .all {
                    return .send(.tabSelected(.register))
                } else {
                    return .send(.routeToExploreSearchScreen)
                }
            case .fetchFilteredFeed:
                return .run { [state] send in
                    // TODO: throttle 공부하고 적용
                    guard !state.isLast else { return }
                    do {
                        let result = try await exploreService.getFilteredFeedList(
                            isLocal: state.selectedFilter.selectedLocal.isEmpty ? false : true,
                            category: state.selectedFilter.selectedCategories.map { $0.id },
                            region: state.selectedFilter.selectedLocations.map { $0.id },
                            age: state.selectedFilter.selectedAges.map {
                                AgeType.toType(from: $0.title)?.key ?? ""
                            },
                            sort: state.selectedSort,
                            cursor: state.nextCursor
                        )
                        let list = result.toEntity()
                        let cursor = result.nextCursor
                        
                        await send(.setFeed(list, cursor))
                    } catch {
                        await send(.error(SNError.networkFail))
                    }
                }
            case .refreshFilteredFeed:
                state.isLoading = true
                state.allList = []
                state.nextCursor = nil
                state.isLast = false
                return .send(.fetchFilteredFeed)
            case .fetchFollowingFeed:
                return .run { send in
                    do {
                        let list = try await exploreService.getFollowingFeedList().toEntity()
                        await send(.setFeed(list, nil))
                    } catch {
                        await send(.error(SNError.networkFail))
                    }
                }
            case .setFeed(let list, let nextCursor):
                if state.viewType == .all {
                    state.allList += list
                } else {
                    state.followingList = list
                }
                
                if state.nextCursor != nil && nextCursor == nil {
                    state.isLast = true
                }
                
                state.isLoading = false
                state.nextCursor = nextCursor
                return .none
            case .setFilterInfo(let category, let region):
                state.filterInfo.categories = category
                state.filterInfo.locations = region
                state.isFilterPresented = true
                return .none
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
                        await send(.error(SNError.networkFail))
                    }
                }
            case .deleteReviewResult(let success):
                if !success {
                    return .send(.error(SNError.networkFail))
                }
                return .send(.refreshFilteredFeed)
            case .routeToEditReviewScreen:
                return .none
            case .routeToExploreSearchScreen:
                return .none
            case .routeToReportScreen:
                return .none
            case .tabSelected:
                return .none
            case .binding(\.selectedFilter):
                state.selectedFilterButton = []
                
                if !state.selectedFilter.selectedLocal.isEmpty {
                    state.selectedFilterButton.append(.local)
                }
                
                if !state.selectedFilter.selectedCategories.isEmpty {
                    state.selectedFilterButton.append(.category)
                }
                
                if !state.selectedFilter.selectedLocations.isEmpty {
                    state.selectedFilterButton.append(.location)
                }
                
                if !state.selectedFilter.selectedAges.isEmpty {
                    state.selectedFilterButton.append(.age)
                }
                
                if !state.selectedFilterButton.isEmpty {
                    state.selectedFilterButton.append(.filter)
                }
                return .send(.refreshFilteredFeed)
            case let .presentAlert(type, alert):
                state.alertType = type
                state.alert = alert
                state.isAlertPresented = true
                return .none
            case .binding(\.selectedSort):
                return .send(.refreshFilteredFeed)
            case .binding:
                return .none
            case .error:
                state.isLoading = false
                return .send(.presentToast(message: "서버에 연결할 수 없습니다.\n잠시 후 다시 시도해 주세요."))
            case .presentToast:
                return .none
            }
        }
    }
    
}

private enum ExploreServiceKey: DependencyKey {
    static let liveValue: ExploreProtocol = DefaultExploreService()
}

extension DependencyValues {
    var exploreService: ExploreProtocol {
        get { self[ExploreServiceKey.self] }
        set { self[ExploreServiceKey.self] = newValue }
    }
}

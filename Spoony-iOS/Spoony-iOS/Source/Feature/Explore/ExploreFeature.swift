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
        
        var viewType: ExploreViewType = .all
        var selectedFilterButton: [FilterButtonType] = []
        
        var allList: [FeedEntity] = []
        var followingList: [FeedEntity] = []
        
        var selectedFilter: SelectedFilterInfo = .init()
        
        var currentFilterTypeIndex: Int = 0
        var selectedSort: SortType = .createdAt
        
        var filterInfo: FilterInfo = .init(categories: [], locations: [])
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case viewOnAppear
        case changeViewType(ExploreViewType)
        case filterTapped(FilterButtonType)
        case searchButtonTapped
        case goButtonTapped
        
        case fetchFilteredFeed
        case fetchFollowingFeed
        
        case setFeed([FeedEntity])
        case setFilterInfo(category: [CategoryChip], location: [Region])
        
        // MARK: - Navigation
        case routeToExploreSearchScreen
        case routeToDetailScreen(FeedEntity)
        case routeToReportScreen(Int)
        case tabSelected(TabType)
    }
    
    @Dependency(\.exploreService) var exploreService: ExploreProtocol
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .viewOnAppear:
                if state.viewType == .all {
                    return .send(.fetchFilteredFeed)
                } else {
                    return .send(.fetchFollowingFeed)
                }
            case .changeViewType(let type):
                state.viewType = type
                switch type {
                case .all:
                    return .send(.fetchFilteredFeed)
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
                    }
                }
            case .routeToDetailScreen:
                // TODO: 명진샘 PostFeature에 navigation back button 눌렀을 때 exploreScreen으로 이동하는 로직 추가해야 함
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
                    do {
                        let list = try await exploreService.getFilteredFeedList(
                            isLocal: state.selectedFilter.selectedLocal.isEmpty ? false : true,
                            category: state.selectedFilter.selectedCategories.map { $0.id },
                            region: state.selectedFilter.selectedLocations.map { $0.id },
                            age: state.selectedFilter.selectedAges.map {
                                AgeType.toType(from: $0.title)?.key ?? ""
                            },
                            sort: state.selectedSort
                        ).toEntity()
                        await send(.setFeed(list))
                    } catch {
                       // 에러처리
                    }
                }
            case .fetchFollowingFeed:
                return .run { send in
                    do {
                        let list = try await exploreService.getFollowingFeedList().toEntity()
                        await send(.setFeed(list))
                    } catch {
                       // 에러처리
                    }
                }
            case .setFeed(let list):
                if state.viewType == .all {
                    state.allList = list
                } else {
                    state.followingList = list
                }
                return .none
            case .setFilterInfo(let category, let region):
                state.filterInfo.categories = category
                state.filterInfo.locations = region
                state.isFilterPresented = true
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
                return .send(.fetchFilteredFeed)
            case .binding(\.selectedSort):
                return .send(.fetchFilteredFeed)
            case .binding:
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

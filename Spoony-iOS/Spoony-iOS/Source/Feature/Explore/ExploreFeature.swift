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
        
        var viewType: ExploreViewType = .all
        var selectedFilterButton: [FilterButtonType] = []
        
        var allList: [FeedEntity] = []
        var followingList: [FeedEntity] = []
        
        var selectedFilter: SelectedFilterInfo = .init()
        
        var currentFilterTypeIndex: Int = 0
        var selectedSort: SortType = .latest
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case changeViewType(ExploreViewType)
        case filterTapped(FilterButtonType)
        case exploreCellTapped(FeedEntity)
        case searchButtonTapped
        case goButtonTapped
        
        // MARK: - Navigation
        case routeToExploreSearchScreen
        case tabSelected(TabType)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .changeViewType(let type):
                state.viewType = type
                return .none
            case .filterTapped(let type):
                if type.rawValue >= 0 {
                    state.currentFilterTypeIndex = type.rawValue
                } else {
                    state.currentFilterTypeIndex = 0
                }
                return .none
            case .exploreCellTapped(let feed):
                // 디테일로 이동
                print("cell tapped!")
                return .none
            case .searchButtonTapped:
                return .send(.routeToExploreSearchScreen)
            case .goButtonTapped:
                if state.viewType == .all {
                    return .send(.tabSelected(.register))
                } else {
                    return .send(.routeToExploreSearchScreen)
                }
            case .routeToExploreSearchScreen:
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
                return .none
            case .binding:
                return .none
            }
            
        }
    }
    
}

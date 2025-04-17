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
        var selectedFilter: [FilterButtonType] = []
        
        var allList: [FeedEntity] = []
        var followingList: [FeedEntity] = []
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case changeViewType(ExploreViewType)
        case filterTapped
        case exploreCellTapped(FeedEntity)
        case searchButtonTapped
        case goButtonTapped
        
        // MARK: - Navigation
        case routeToExploreSearchScreen
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .changeViewType(let type):
                state.viewType = type
                return .none
            case .filterTapped:
                print("filter tapped")
                return .none
            case .exploreCellTapped(let feed):
                // 디테일로 이동
                print("cell tapped!")
                return .none
            case .searchButtonTapped:
                return .send(.routeToExploreSearchScreen)
            case .goButtonTapped:
                if state.viewType == .all {
                    // 등록 탭으로 이동
                    print("등록 탭으로 이동")
                } else {
                    return .send(.routeToExploreSearchScreen)
                }
                return .none
            case .routeToExploreSearchScreen:
                return .none
            case .binding:
                return .none
            }
            
        }
    }
    
}

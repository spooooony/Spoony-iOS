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
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case changeViewType(ExploreViewType)
        
        // MARK: - Navigation
        case routToExploreScreen
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .changeViewType(let type):
                state.viewType = type
                return .none
            case .routToExploreScreen:
                return .none
            case .binding:
                return .none
            }
            
        }
    }
    
}

//
//  MapFeature.swift
//  Spoony-iOS
//
//  Created by 최안용 on 4/6/25.
//

import Foundation

import ComposableArchitecture

@Reducer
struct MapFeature {
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
    }
    
    enum Action {
        case routToSearchScreen
        case routToExploreTab
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .routToSearchScreen, .routToExploreTab:
                return .none
            }
        }
    }
}

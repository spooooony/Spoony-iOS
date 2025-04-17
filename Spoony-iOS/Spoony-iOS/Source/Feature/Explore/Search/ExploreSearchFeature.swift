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
    }
    
    enum Action {
        
        // MARK: - Navigation
        case routeToExploreScreen
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .routeToExploreScreen :
                return .none
            }
        }
    }
}

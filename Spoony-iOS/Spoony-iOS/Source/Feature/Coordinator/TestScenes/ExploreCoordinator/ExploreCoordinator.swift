//
//  ExploreCoordinator.swift
//  Spoony-iOS
//
//  Created by 최안용 on 4/4/25.
//

import ComposableArchitecture
import SwiftUI

// MARK: - ExploreCoordinator
@Reducer
struct ExploreCoordinator {
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
    }
    
    enum Action {}
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
        }
    }
}

struct ExploreView: View {
    let store: StoreOf<ExploreCoordinator>
    
    var body: some View {
        Text("Explore View")
    }
}

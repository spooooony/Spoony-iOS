//
//  MapCoordinator.swift
//  Spoony-iOS
//
//  Created by 최안용 on 4/4/25.
//


import ComposableArchitecture
import SwiftUI

// MARK: - MapCoordinator
@Reducer
struct MapCoordinator {
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

struct MapView: View {
    let store: StoreOf<MapCoordinator>
    
    var body: some View {
        Text("Map View")
    }
}
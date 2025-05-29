//
//  MapCoordinatorView.swift
//  Spoony-iOS
//
//  Created by 최안용 on 4/6/25.
//

import SwiftUI

import ComposableArchitecture
import TCACoordinators

struct MapCoordinatorView: View {
    private let store: StoreOf<MapCoordinator>
    
    init(store: StoreOf<MapCoordinator>) {
        self.store = store
    }
    
    var body: some View {
        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            switch screen.case {
            case let .map(store):
                Home(store: store)
            case let .search(store):
                SearchView(store: store)
            case let .searchLocation(store):
                SearchLocationView(store: store)
            }
        }
    }
}

#Preview {
    MapCoordinatorView(
        store: Store(initialState: .initialState) {
            MapCoordinator()
        }
    )
}

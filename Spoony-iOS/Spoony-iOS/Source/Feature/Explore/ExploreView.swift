//
//  ExploreView.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/17/25.
//

import SwiftUI

import ComposableArchitecture
import TCACoordinators

@Reducer(state: .equatable)
enum ExploreScreen {
    case explore(ExploreFeature)
    case search(ExploreSearchFeature)
}

struct ExploreView: View {
    @Bindable private var store: StoreOf<ExploreCoordinator>
    
    init(store: StoreOf<ExploreCoordinator>) {
        self.store = store
    }
    
    var body: some View {
        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            
            switch screen.case {
            case .explore(let store):
                Explore(store: store)
            case .search(let store):
                ExploreSearchView(store: store)
            }
            
        }
    }
}

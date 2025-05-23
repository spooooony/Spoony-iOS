//
//  ExploreCoordinatorView.swift
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
    case detail(PostFeature)
    case report(ReportFeature)
    case edit(RegisterFeature)
//    case profile(ProfileFeature)
    case otherProfile(OtherProfileFeature)
}

struct ExploreCoordinatorView: View {
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
            case .detail(let store):
                PostView(postId: store.postId, store: store)
            case .report(let store):
                Report(postId: store.postId, userId: nil, store: store)
            case .edit(let store):
                Register(store: store)
            case .otherProfile(let store):
                OtherProfileView(store: store)
//            case .profile(let store):
//                ProfileView(store: store)
            }
            
        }
    }
}

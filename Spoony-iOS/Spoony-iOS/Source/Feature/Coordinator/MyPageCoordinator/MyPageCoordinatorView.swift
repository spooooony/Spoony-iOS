//
//  MyPageView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/11/25.
//

import SwiftUI

import ComposableArchitecture
import TCACoordinators

struct MyPageCoordinatorView: View {
    @Bindable private var store: StoreOf<MyPageCoordinator>
    
    init(store: StoreOf<MyPageCoordinator>) {
        self.store = store
    }
    
    var body: some View {
        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            switch screen.case {
            case let .profile(store):
                ProfileView(store: store)
                    .navigationBarBackButtonHidden()
            case let .otherProfile(store):
                OtherProfileView(store: store)
                    .navigationBarBackButtonHidden()
            case let .reviews(store):
                Register(store: store)
            case let .follow(store):
                FollowListView(store: store)
                    .navigationBarBackButtonHidden()
            }
        }
    }
}

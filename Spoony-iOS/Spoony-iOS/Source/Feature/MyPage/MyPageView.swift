//
//  MyPageView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/11/25.
//

import SwiftUI

import ComposableArchitecture
import TCACoordinators

@Reducer(state: .equatable)
enum MyPageScreen {
    case profile(ProfileFeature)
    case reviews(ReviewsFeature)
    case following(FollowingFeature)
    case follower(FollowerFeature)
    case editProfile(EditProfileFeature)
    case settings(SettingsFeature)
    case attendance(AttendanceFeature)
}

struct MyPageView: View {
    @Bindable private var store: StoreOf<MyPageCoordinator>
    
    init(store: StoreOf<MyPageCoordinator>) {
        self.store = store
    }
    
    var body: some View {
        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            switch screen.case {
            case let .profile(store):
                ProfileView(store: store)
            case let .reviews(store):
                ReviewsView(store: store)
            case let .following(store):
                FollowListView()
            case let .follower(store):
                FollowListView()
            case let .editProfile(store):
                EditProfileView(store: store)
            case let .settings(store):
                SettingsView(store: store)
            case let .attendance(store):
                MealTrackerView(store: store)
                    .navigationBarBackButtonHidden()
                    .toolbar(.hidden, for: .tabBar)
            }
        }
    }
}

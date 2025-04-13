//
//  ProfileFeature.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/13/25.
//

import SwiftUI

import ComposableArchitecture
import TCACoordinators

@Reducer
struct ProfileFeature {
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
        var username: String = "서울 마포구 스푼"
        var location: String = "크리스탈에메랄드수정"
        var spoonCount: Int = 99
        var reviewCount: Int = 0
        var followingCount: Int = 0
        var followerCount: Int = 0
    }
    
    enum Action {
        case routeToReviewsScreen
        case routeToFollowingScreen
        case routeToFollowerScreen
        case routeToEditProfileScreen
        case routeToSettingsScreen
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .routeToReviewsScreen, .routeToFollowingScreen,
                    .routeToFollowerScreen, .routeToEditProfileScreen,
                    .routeToSettingsScreen:
                return .none
            }
        }
    }
}

//
//  FollowingView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/13/25.
//

import SwiftUI

import ComposableArchitecture
import TCACoordinators

//팔로잉
struct FollowingView: View {
    @Bindable private var store: StoreOf<FollowingFeature>
    
    init(store: StoreOf<FollowingFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            CustomNavigationBar(
                style: .detail,
                searchText: .constant(""),
                onBackTapped: {
                    store.send(.routeToPreviousScreen)
                }
            )
            
            Spacer()
            
            Text("Following View")
                .font(.largeTitle)
            
            Spacer()
        }
    }
}


// 팔로워 
struct FollowerView: View {
    @Bindable private var store: StoreOf<FollowerFeature>
    
    init(store: StoreOf<FollowerFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            CustomNavigationBar(
                style: .detail,
                searchText: .constant(""),
                onBackTapped: {
                    store.send(.routeToPreviousScreen)
                }
            )
            
            Spacer()
            
            Text("Follower View")
                .font(.largeTitle)
            
            Spacer()
        }
    }
}

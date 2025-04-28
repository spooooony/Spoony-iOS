//
//  BlockedUsersView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/25/25.
//

import SwiftUI
import ComposableArchitecture

struct BlockedUsersView: View {
    @Bindable private var store: StoreOf<BlockedUsersFeature>
    
    init(store: StoreOf<BlockedUsersFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            CustomNavigationBar(
                style: .detail,
                title: "차단한 유저",
                searchText: .constant(""),
                onBackTapped: {
                    store.send(.routeToPreviousScreen)
                }
            )
            
            Spacer()
            
            Text("차단한 유저 화면")
                .font(.title2)
            
            Spacer()
        }
        .background(Color.white)
        .navigationBarHidden(true)
    }
}

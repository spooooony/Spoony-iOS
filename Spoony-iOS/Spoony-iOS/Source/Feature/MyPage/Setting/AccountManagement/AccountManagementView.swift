//
//  AccountManagementView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/25/25.
//

import SwiftUI
import ComposableArchitecture

struct AccountManagementView: View {
    @Bindable private var store: StoreOf<AccountManagementFeature>
    
    init(store: StoreOf<AccountManagementFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            CustomNavigationBar(
                style: .detail,
                title: "계정 관리",
                searchText: .constant(""),
                onBackTapped: {
                    store.send(.routeToPreviousScreen)
                }
            )
            
            Spacer()
            
            Text("계정 관리 화면")
                .font(.title2)
            
            Spacer()
        }
        .background(Color.white)
        .navigationBarHidden(true)
    }
}

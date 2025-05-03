//
//  WithdrawView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 5/3/25.
//

import SwiftUI
import ComposableArchitecture

struct WithdrawView: View {
    @Bindable private var store: StoreOf<WithdrawFeature>
    
    init(store: StoreOf<WithdrawFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                style: .detail,
                title: "회원 탈퇴",
                onBackTapped: {
                    store.send(.routeToPreviousScreen)
                }
            )
            
            
        }
    }
}

#Preview {
    WithdrawView(
        store: Store(initialState: .initialState) {
            WithdrawFeature()
        }
    )
}

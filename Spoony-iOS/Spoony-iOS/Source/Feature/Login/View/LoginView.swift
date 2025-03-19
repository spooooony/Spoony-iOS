//
//  LoginView.swift
//  Spoony-iOS
//
//  Created by 최주리 on 3/12/25.
//

import SwiftUI

import ComposableArchitecture

struct LoginView: View {
    let store: StoreOf<LoginFeature>
    
    var body: some View {
        VStack {
            Text("카카오로그인")
                .onTapGesture {
                    store.send(.kakaoLoginButtonTapped)
                }
            Text("애플로그인")
                .onTapGesture {
                    store.send(.appleLoginButtonTapped)
                }
        }
    }
}

#Preview {
    LoginView(store: Store(initialState: LoginFeature.State(), reducer: {
        LoginFeature()
    }))
}

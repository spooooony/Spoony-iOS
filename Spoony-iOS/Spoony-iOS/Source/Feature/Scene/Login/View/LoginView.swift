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
        ZStack {
            Image(.imageLoginBg)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                Image(.spoonyEnglishLogo)
                    .padding(.bottom, 330)
                    .padding(.top, 200)
                
                Image(.imageKakaoLogin)
                    .onTapGesture {
                        store.send(.kakaoLoginButtonTapped)
                    }
                    .padding(.bottom, 16)
                
                Image(.imageAppleLogin)
                    .onTapGesture {
                        store.send(.appleLoginButtonTapped)
                    }
                    .padding(.bottom, 70)
            }
            
            if store.state.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .transition(.opacity)
                    .animation(.easeInOut, value: store.state.isLoading)
            }
        }
        .allowsHitTesting(!store.state.isLoading)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    LoginView(store: Store(initialState: LoginFeature.State(), reducer: {
        LoginFeature()
    }))
}

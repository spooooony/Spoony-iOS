//
//  LogoutView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 5/3/25.
//

import SwiftUI
import ComposableArchitecture

struct LogoutView: View {
    @Bindable private var store: StoreOf<LogoutFeature>
    
    init(store: StoreOf<LogoutFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                style: .detail,
                title: "로그아웃",
                onBackTapped: {
                    store.send(.routeToPreviousScreen)
                }
            )
            
            VStack(spacing: 20) {
                Spacer()
                
                
                Text("로그아웃 하시겠습니까?")
                    .customFont(.title3b)
                    .foregroundStyle(.spoonBlack)
                
                Text("로그아웃 시 스푸니 서비스 이용이 제한됩니다.")
                    .customFont(.body2m)
                    .foregroundStyle(.gray500)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 16) {
                    // 취소 버튼
                    Button(action: {
                        store.send(.routeToPreviousScreen)
                    }) {
                        Text("취소")
                            .customFont(.body2sb)
                            .foregroundStyle(.gray600)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray200, lineWidth: 1)
                                    )
                            )
                    }
                    
                    // 로그아웃 버튼
                    Button(action: {
                        store.send(.logoutButtonTapped)
                    }) {
                        Text("로그아웃")
                            .customFont(.body2sb)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                            )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 40)
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .overlay {
            if store.isLoggingOut {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.3))
            }
        }
       
    }
}

#Preview {
    LogoutView(
        store: Store(initialState: .initialState) {
            LogoutFeature()
        }
    )
}

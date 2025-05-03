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
        VStack(spacing: 0) {
            CustomNavigationBar(
                style: .detail,
                title: "계정 관리",
                onBackTapped: {
                    store.send(.routeToPreviousScreen)
                }
            ).background(Color.white)
            
            Divider()
                .frame(height: 1)
                .foregroundStyle(.gray0)
            
            HStack(spacing: 0) {
                Text("간편 로그인")
                    .padding(.leading, 20)
                    .customFont(.body2m)
                    .foregroundStyle(.gray700)
                
                Spacer()
                
                Text(loginTypeText)
                    .padding(.trailing, 20)
                    .customFont(.body2b)
                    .foregroundStyle(.gray600)
            }
            .frame(height: 48.adjustedH)
            .background(Color.white)
            
            Button(action: {
                store.send(.logoutButtonTapped)
            }) {
                HStack {
                    Text("로그아웃")
                        .customFont(.body2m)
                        .foregroundColor(.main400)
                        .padding(.leading, 20)
                    
                    Spacer()
                    
                    Image(.icArrowRightGray400)
                        .padding(.trailing, 20)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48.adjustedH)
            }
            .background(Color.white)
            .padding(.top, 10)
            
            Button(action: {
                store.send(.withdrawButtonTapped)
            }) {
                HStack {
                    Text("탈퇴하기")
                        .customFont(.body2m)
                        .foregroundColor(.gray500)
                        .padding(.leading, 20)
                    
                    Spacer()
                    
                    Image(.icArrowRightGray400)
                        .padding(.trailing, 20)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48.adjustedH)
            }
            .background(Color.white)
            .padding(.top, 10)
            
            Spacer()
        }
        .background(Color.gray0)
        .navigationBarHidden(true)
        .alert(
            "로그아웃",
            isPresented: .init(
                get: { store.logoutAlert != nil },
                set: { if !$0 { store.send(.cancelLogout) } }
            ),
            actions: {
                Button("취소", role: .cancel) {
                    store.send(.cancelLogout)
                }
                Button("확인", role: .destructive) {
                    store.send(.confirmLogout)
                }
            },
            message: { Text("정말 로그아웃 하시겠습니까?") }
        )
    }
    
    private var loginTypeText: String {
        switch store.currentLoginType {
        case .apple:
            return "애플 로그인 사용 중"
        case .kakao:
            return "카카오 로그인 사용 중"
        }
    }
}

#Preview {
    AccountManagementView(
        store: Store(initialState: .initialState) {
            AccountManagementFeature()
        }
    )
}

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
            // 네비게이션 바
            CustomNavigationBar(
                style: .detail,
                title: "계정 관리",
                onBackTapped: {
                    store.send(.routeToPreviousScreen)
                }
            )
            
            // 로그인 타입 섹션
            VStack(spacing: 0) {
               
                
                Divider().padding(.leading, 20)
                
                // 카카오 로그인 버튼
                loginTypeButton(
                    title: "카카오 로그인 사용 중",
                    isSelected: store.currentLoginType == .kakao,
                    action: { store.send(.selectLoginType(.kakao)) }
                )
            }
            .background(Color.white)
            .cornerRadius(8)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // 로그아웃 버튼
            Button(action: {
                store.send(.logoutButtonTapped)
            }) {
                HStack {
                    Text("로그아웃")
                        .customFont(.body2m)
                        .foregroundColor(.main400)
                    
                    Spacer()
                    
                    Image(.icArrowRightGray400)
                }
                .padding(.horizontal, 20)
                .frame(height: 50)
            }
            .background(Color.white)
            .cornerRadius(8)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // 탈퇴하기 버튼
            Button(action: {
                store.send(.withdrawButtonTapped)
            }) {
                HStack {
                    Text("탈퇴하기")
                        .customFont(.body2m)
                        .foregroundColor(.gray600)
                    
                    Spacer()
                    
                    Image(.icArrowRightGray400)
                }
                .padding(.horizontal, 20)
                .frame(height: 50)
            }
            .background(Color.white)
            .cornerRadius(8)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            Spacer()
        }
        .background(Color.gray0)
        .navigationBarHidden(true)
    }
    
    private func loginTypeButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .customFont(.body2m)
                    .foregroundColor(.gray700)
                
                Spacer()
                
                if isSelected {
                    Circle()
                        .fill(Color.main400)
                        .frame(width: 20, height: 20)
                }
            }
            .padding(.horizontal, 20)
            .frame(height: 50)
            .contentShape(Rectangle())
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

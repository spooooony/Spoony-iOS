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
            ).background(Color.white)
            
            Divider()
                .frame(height: 1)
                .foregroundStyle(.gray100)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    bulletPointList

                    HStack {
                        Button(action: {
                            store.send(.toggleAgreement)
                        }) {
                            Image(store.isAgreed ? "ic_checkboxfilled_main" : "ic_checkboxempty_gray400")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        
                        Text("위 유의사항을 확인했습니다.")
                            .customFont(.body2m)
                            .foregroundColor(.spoonBlack)
                            .padding(.leading, 8)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
            
                    SpoonyButton(
                        style: .primary,
                        size: .xlarge,
                        title: store.isWithdrawing ? "탈퇴 처리 중..." : "탈퇴하기",
                        disabled: .init(get: { !store.isAgreed || store.isWithdrawing }, set: { _ in })
                    ) {
                        if store.isAgreed && !store.isWithdrawing {
                            store.send(.withdrawButtonTapped)
                        }
                    }
                    .padding(.top, 12)
                    .padding(.horizontal, 20)
                    
                    // 에러 메시지 표시
                    if let errorMessage = store.withdrawErrorMessage {
                        Text(errorMessage)
                            .customFont(.caption1m)
                            .foregroundColor(.red)
                            .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                }
            }
        }
        .background(Color.white)
        .overlay {
            if store.isWithdrawing {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.3))
            }
        }
    }
    
    private var bulletPointList: some View {
        VStack(alignment: .leading, spacing: 16) {
            BulletPointText(text: "회원 탈퇴 시, 즉시 탈퇴 처리되며 서비스 이용이 불가해요.")
            BulletPointText(text: "탈퇴 시 모든 정보가 사라지며, 회원님의 소중한 정보를 되살릴 수 없어요.")
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }
}

#Preview {
    WithdrawView(
        store: Store(initialState: .initialState) {
            WithdrawFeature()
        }
    )
}

//
//  PrivacyPolicyView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/25/25.
//

import SwiftUI
import ComposableArchitecture

struct PrivacyPolicyView: View {
    @Bindable private var store: StoreOf<PrivacyPolicyFeature>
    
    init(store: StoreOf<PrivacyPolicyFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            CustomNavigationBar(
                style: .detail,
                title: "개인정보 처리 방침",
                searchText: .constant(""),
                onBackTapped: {
                    store.send(.routeToPreviousScreen)
                }
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("개인정보 처리 방침")
                        .font(.title3b)
                        .padding(.top, 20)
                    
                    Text("이 방침은 스푸니의 개인정보 처리 방법에 대한 내용을 담고 있습니다.")
                        .font(.body2m)
                        .foregroundStyle(.gray700)
                        .padding(.bottom, 20)
                    
                    Text("개인정보 처리 방침 내용이 여기에 표시됩니다.")
                        .font(.body2m)
                        .foregroundStyle(.gray700)
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
    }
}

#Preview {
    PrivacyPolicyView(store: Store(initialState: .initialState, reducer: {
        PrivacyPolicyFeature()
    }))
}

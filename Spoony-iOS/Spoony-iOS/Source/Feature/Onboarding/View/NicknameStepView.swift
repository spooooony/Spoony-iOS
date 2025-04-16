//
//  NicknameStepView.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/1/25.
//

import SwiftUI
import ComposableArchitecture

struct NicknameStepView: View {
    @Bindable private var store: StoreOf<OnboardingFeature>
    @FocusState private var isFocused: Bool
    
    init(store: StoreOf<OnboardingFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("닉네임을 입력해 주세요")
                .customFont(.title3b)
                .padding(.top, 32)
            
            NicknameTextField(errorState: $store.nicknameErrorState,
                              text: $store.nicknameText,
                              isError: $store.nicknameError)
            .padding(.top, 28)
            .focused($isFocused)
            .onSubmit {
                store.send(.checkNickname)
                hideKeyboard()
            }
            
            Spacer()
            
            SpoonyButton(
                style: .primary,
                size: .xlarge,
                title: "다음",
                disabled: $store.nicknameError
            ) {
                store.send(.tappedNextButton)
            }
            .padding(.bottom, 20)
        }
        
    }
}

#Preview {
    NicknameStepView(store: StoreOf<OnboardingFeature>(initialState: OnboardingFeature.State(), reducer: {
        OnboardingFeature()
    }) )
}

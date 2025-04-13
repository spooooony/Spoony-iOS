//
//  UserIntroduceView.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/13/25.
//

import SwiftUI
import ComposableArchitecture

struct UserIntroduceView: View {
    @Bindable private var store: StoreOf<OnboardingFeature>
    
    init(store: StoreOf<OnboardingFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("간단한 자기소개를 입력해 주세요")
                .customFont(.title3b)
                .padding(.top, 32)
            
            SpoonyTextEditor(
                text: $store.state.introduceText,
                style: .onboarding,
                placeholder: "안녕! 나는 어떤 스푼이냐면...",
                isError: $store.state.introduceError
            )
            .padding(.top, 28)
            
            Spacer()
            
            SpoonyButton(style: .primary, size: .xlarge, title: "다음", disabled: $store.state.introduceError) {
                store.send(.tappedNextButton)
            }
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    UserIntroduceView(store: StoreOf<OnboardingFeature>(initialState: OnboardingFeature.State(), reducer: {
        OnboardingFeature()
    }) )
}

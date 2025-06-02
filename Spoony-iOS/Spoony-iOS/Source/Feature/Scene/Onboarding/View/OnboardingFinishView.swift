//
//  OnboardingFinishView.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/13/25.
//

import SwiftUI
import ComposableArchitecture

struct OnboardingFinishView: View {
    @Bindable private var store: StoreOf<OnboardingFeature>
    
    init(store: StoreOf<OnboardingFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Text("반가워요,")
                Text(store.state.userNickname)
                    .foregroundStyle(.main400)
                Text("님!")
            }
            .customFont(.title2)
            .padding(.top, 62)
            
            Text("이제 스푸니를 시작해 볼까요?")
                .customFont(.title2)
                .padding(.top, 4)
            
            // TODO: Lottie
            Rectangle()
                .frame(width: 335.adjusted, height: 406.adjustedH)
                .foregroundStyle(.gray200)
                .padding(.top, 37)
            Spacer()
            
            VStack(spacing: 16) {
                Text("내 프로필 정보는 마이페이지에서 변경할 수 있어요")
                    .customFont(.caption1m)
                    .foregroundStyle(.gray400)
                
                SpoonyButton(style: .primary, size: .xlarge, title: "스푸니 시작하기 ", disabled: .constant(false)) {
                    store.send(.tappedNextButton)
                }
            }
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    OnboardingFinishView(store: StoreOf<OnboardingFeature>(initialState: OnboardingFeature.State(), reducer: {
        OnboardingFeature()
    }) )
}

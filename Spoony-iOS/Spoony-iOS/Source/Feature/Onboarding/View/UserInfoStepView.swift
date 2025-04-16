//
//  UserInfoStepView.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/5/25.
//

import SwiftUI
import ComposableArchitecture

struct UserInfoStepView: View {
    @Bindable private var store: StoreOf<OnboardingFeature>
    
    private var isRegionSelected: Bool = true

    init(store: StoreOf<OnboardingFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            birthView
            regionView

            Spacer()
    
            SpoonyButton(
                style: .primary,
                size: .xlarge,
                title: "다음",
                disabled: $store.state.infoError
            ) {
                store.send(.tappedNextButton)
            }
            .padding(.bottom, 20)
        }
    }
}

extension UserInfoStepView {
    
    private var birthView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("생년월일을 입력해 주세요")
                .customFont(.title3b)
                .padding(.top, 32)
            
            SpoonyDatePicker(selectedDate: $store.birth)
                .padding(.top, 28)
                .frame(maxWidth: .infinity)
        }
    }
    
    private var regionView: some View {
        VStack(alignment: .leading, spacing: 28) {
            Text("주로 활동하는 지역을 설정해 주세요")
                .customFont(.title3b)
                .padding(.top, 32)
            
            SpoonyLocationPicker(
                selectedLocation: $store.state.region,
                selectedSubLocation: $store.subRegion
            )
        }
    }
}

#Preview {
    UserInfoStepView(store: StoreOf<OnboardingFeature>(initialState: OnboardingFeature.State(), reducer: {
        OnboardingFeature()
    }) )
}

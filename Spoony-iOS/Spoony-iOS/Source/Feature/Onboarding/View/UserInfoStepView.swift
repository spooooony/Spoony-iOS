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
    
    private var isDateSelected: Bool = true
    private var isRegionSelected: Bool = true
    
    init(store: StoreOf<OnboardingFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            birthView
                .onTapGesture {
                    store.send(.tappedBirthButton)
                }
            regionView
                .onTapGesture {
                    store.send(.tappedRegionButton)
                }
            
            Spacer()
    
            SpoonyButton(style: .primary, size: .xlarge, title: "다음", disabled: $store.state.infoError) {
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
            
            HStack(spacing: 21) {
                HStack(spacing: 10) {
                    placeholderView("2000")
                    Text("년")
                }
                HStack(spacing: 10) {
                    placeholderView("01")
                    Text("월")
                }
                HStack(spacing: 10) {
                    placeholderView("01")
                    Text("일")
                }
            }
            .padding(.top, 28)
            .customFont(.body1m)
            .foregroundStyle(.gray500)
        }
    }
    
    private var regionView: some View {
        VStack(alignment: .leading, spacing: 28) {
            Text("주로 활동하는 지역을 설정해 주세요")
                .customFont(.title3b)
                .padding(.top, 32)
            
            HStack(spacing: 22) {
                Text("나는")
                placeholderWithImageView("서울 마포구")
                Text("스푼")
            }
            .frame(maxWidth: .infinity)
            .customFont(.body1m)
        }
    }
    
    private func placeholderView(_ text: String) -> some View {
        HStack {
            Text("\(text)")
                .customFont(.body1m)
                .foregroundStyle(isDateSelected ? .spoonBlack : .gray500)
                .padding(.horizontal, 24)
        }
        .frame(height: 44.adjustedH)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.gray100), lineWidth: 1)
        )
    }
    
    private func placeholderWithImageView(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(.icSpoonGray600)
                .renderingMode(.template)
                .foregroundStyle(isRegionSelected ? .main400 : .gray400)
            
            Text("\(text)")
                .customFont(.body2m)
                .foregroundStyle(isRegionSelected ? .spoonBlack : .gray400)
        }
        .frame(height: 44.adjustedH)
        .padding(.horizontal, 16)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.gray100), lineWidth: 1)
        )
    }
}

#Preview {
    UserInfoStepView(store: StoreOf<OnboardingFeature>(initialState: OnboardingFeature.State(), reducer: {
        OnboardingFeature()
    }) )
}

//
//  OnboardingView.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/13/25.
//

import SwiftUI
import ComposableArchitecture

struct OnboardingView: View {
    @Bindable private var store: StoreOf<OnboardingFeature>
    
    init(store: StoreOf<OnboardingFeature>) {
        self.store = store
    }
    
    var body: some View {
        GeometryReader { _ in
            VStack {
                if store.currentStep != .finish {
                    navigationBar
                }
                
                Group {
                    switch store.state.currentStep {
                    case .nickname:
                        NicknameStepView(store: store)
                    case .information:
                        UserInfoStepView(store: store)
                            .onAppear {
                                store.send(.viewAction(.infoStepViewOnAppear))
                            }
                    case .introduce:
                        UserIntroduceView(store: store)
                    case .finish:
                        OnboardingFinishView(store: store)
                    }
                }
                
            }
            .padding(.horizontal, 20)
            .background(.white)
            .onTapGesture {
                hideKeyboard()
                
                if store.state.currentStep == .nickname {
                    store.send(.viewAction(.checkNickname))
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

extension OnboardingView {
    private var navigationBar: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                style: .onboarding,
                onBackTapped: {
                    store.send(.viewAction(.tappedBackButton))
                }, tappedAction: {
                    store.send(.viewAction(.tappedSkipButton))
                })
            .isHidden(store.state.currentStep == .nickname)
            .padding(.horizontal, -20)
            
            progressBar
        }
    }
    
    private var progressBar: some View {
        ProgressView(value: 1.0/3 * Double(store.state.currentStep.rawValue))
            .frame(height: 4.adjustedH)
            .progressViewStyle(.linear)
            .tint(.main400)
            .animation(.easeInOut, value: store.state.currentStep)
    }
}

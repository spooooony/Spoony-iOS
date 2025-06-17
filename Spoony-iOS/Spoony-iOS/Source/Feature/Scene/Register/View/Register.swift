//
//  Register.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/2/25.
//

import SwiftUI

import ComposableArchitecture

struct Register: View {
    @Bindable private var store: StoreOf<RegisterFeature>
    
    init(store: StoreOf<RegisterFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack(spacing: 0) {
            customNavigationBar
            
            if store.state.isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                        .tint(.main400)
                    Spacer()
                }
            } else {
                ScrollView {
                    Group {
                        switch store.state.currentStep {
                        case .start:
                            InfoStepView(store: store.scope(state: \.infoStepState, action: \.infoStepAction))
                        case .end:
                            ReviewStepView(store: store.scope(state: \.reviewStepState, action: \.reviewStepAction))
                        }
                    }
                    .transition(.slide)
                    .animation(.easeInOut, value: store.state.currentStep)
                }
                .scrollIndicators(.hidden)
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { _ in
                            hideKeyboard()
                        }
                )
            }
        }
        .onAppear {
<<<<<<< Updated upstream
            store.send(.onAppear)
=======
            Task {
                await store.send(.onAppear).finish()
            }
>>>>>>> Stashed changes
        }
    }
}

extension Register {
    private var customNavigationBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Button {
                    if store.state.currentStep == .start {
                        store.send(.routeToPreviousScreen)
                    } else {
                        store.send(.reviewStepAction(.movePreviousView))
                    }
                } label: {
                    Image(.icArrowLeftGray700)
                        .resizable()
                        .frame(width: 24.adjusted, height: 24.adjustedH)
                }
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .frame(height: 56.adjustedH)
            
            progressBar
        }
    }
    
    private var progressBar: some View {
        ProgressView(value: 1.0/2 * Double(store.state.currentStep.rawValue))
            .frame(height: 4.adjustedH)
            .progressViewStyle(.linear)
            .tint(.main400)
            .padding(.horizontal, 20)
            .animation(.easeInOut, value: store.state.currentStep)
    }
}

#Preview {
    Register(store: Store(initialState: .initialState, reducer: {
        RegisterFeature()
            ._printChanges()
    }))
}

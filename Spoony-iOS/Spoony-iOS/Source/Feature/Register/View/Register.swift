//
//  Register.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/2/25.
//

import SwiftUI

struct Register: View {
    @StateObject var store: RegisterStore
    
    var body: some View {
        VStack(spacing: 0) {
            customNavigationBar
            
            ScrollView {
                Group {
                    switch store.state.registerStep {
                    case .start:
                        InfoStepView(store: store)
                    case .middle, .end:
                        ReviewStepView(store: store)
                    }
                }
                .transition(.slide)
                .animation(.easeInOut, value: store.state.registerStep)
            }
        }
    }
}

extension Register {
    private var customNavigationBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                if store.state.registerStep != .start {
                    Button {
                        store.dispatch(.movePreviousView)
                    } label: {
                        Image(.icArrowLeftGray700)
                            .resizable()
                            .frame(width: 24.adjusted, height: 24.adjustedH)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 12)
            .frame(height: 56.adjustedH)
            
            progressBar
        }
    }
    
    private var progressBar: some View {
        ProgressView(value: 1.0/3 * Double(store.state.registerStep.rawValue))
            .frame(height: 4.adjustedH)
            .progressViewStyle(.linear)
            .tint(.main400)
            .padding(.horizontal, 20)
            .animation(.easeInOut, value: store.state.registerStep)
    }
}

enum RegisterStep: Int {
    case start = 1
    case middle = 2
    case end = 3
}

#Preview {
    Register(store: .init(navigationManager: .init()))
}

//
//  Register.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/2/25.
//

import SwiftUI

struct Register: View {
    @StateObject private var store: RegisterStore = RegisterStore()
    
    var body: some View {
        VStack(spacing: 0) {
            customNavigationBar
            
            ScrollView {
                Group {
                    switch store.step {
                    case .start:
                        InfoStepView(store: store) {
                            hideKeyboard()
                        }
                    case .middle:
                        VStack {
                            HStack {
                                Spacer()
                                Text("2번째 화면")
                                Spacer()
                            }
                        }
                        .frame(height: 500)
                    case .end:
                        Text("끝")
                    }
                }
                .transition(.slide)
                .animation(.easeInOut, value: store.step)
            }
        }
    }
}

extension Register {
    private var customNavigationBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                if store.step != .start {
                    Button {
                        store.step = .start
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
        ProgressView(value: 1.0/3 * Double(store.step.rawValue))
            .frame(height: 4.adjustedH)
            .progressViewStyle(.linear)
            .tint(.main400)
            .padding(.horizontal, 20)
            .animation(.easeInOut, value: store.step)
    }
}

enum RegisterStep: Int {
    case start = 1
    case middle = 2
    case end = 3
}

#Preview {
    Register()
}

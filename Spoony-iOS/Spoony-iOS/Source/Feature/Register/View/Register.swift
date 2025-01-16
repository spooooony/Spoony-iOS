//
//  Register.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/2/25.
//

import SwiftUI

/// 프로그래스바 고정

struct Register: View {
    @StateObject var store: RegisterStore = RegisterStore()
    
    var body: some View {
        VStack(spacing: 0) {
            customNavigationBar
            
            ScrollView {
                Group {
                    switch store.step {
                    case .start:
                        InfoStepView(store: store)
                    case .middle:
                        Text("중간")
                    case .end:
                        Text("끝")
                    }
                }
                .transition(.slide)
                .animation(.easeInOut, value: store.step)
                Button {
                    store.step = .middle
                } label: {
                    Text("다음")
                }
            }
        }
    }
}

extension Register {
    private var progressBar: some View {
        ProgressView(value: 1.0/3 * Double(store.step.rawValue))
            
            .progressViewStyle(.linear)
            .tint(.main400)
            .padding(.horizontal, 20)
            .animation(.easeInOut, value: store.step)
    }
    
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
}

enum RegisterStep: Int {
    case start = 1
    case middle = 2
    case end = 3
}


#Preview {
    Register()
}

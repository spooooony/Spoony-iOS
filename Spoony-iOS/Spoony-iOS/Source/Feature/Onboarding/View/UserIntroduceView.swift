//
//  UserIntroduceView.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/13/25.
//

import SwiftUI

struct UserIntroduceView: View {
    let step: Int = 3
    @State private var text: String = ""
    @State private var isError: Bool = true
    
    var body: some View {
        GeometryReader { _ in
            VStack(alignment: .leading, spacing: 0) {
                CustomNavigationBar(style: .onboarding)
                    .padding(.horizontal, -20)
                progressBar
                
                Text("간단한 자기소개를 입력해 주세요")
                    .customFont(.title3b)
                    .padding(.top, 32)
                
                SpoonyTextEditor(
                    text: $text,
                    style: .onboarding,
                    placeholder: "안녕! 나는 어떤 스푼이냐면...",
                    isError: $isError
                )
                .padding(.top, 28)
                
                Spacer()
                
                SpoonyButton(style: .primary, size: .xlarge, title: "다음", disabled: $isError) {
                    // TODO: 회원 가입 API 호출
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
            .background(.white)
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
}

extension UserIntroduceView {
    private var progressBar: some View {
        ProgressView(value: 1.0/3 * Double(step))
            .frame(height: 4.adjustedH)
            .progressViewStyle(.linear)
            .tint(.main400)
            .animation(.easeInOut, value: step)
    }
}

#Preview {
    UserIntroduceView()
}

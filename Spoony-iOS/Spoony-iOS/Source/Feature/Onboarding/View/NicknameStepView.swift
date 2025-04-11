//
//  NicknameStepView.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/1/25.
//

import SwiftUI

struct NicknameStepView: View {
    @State private var text: String = ""
    @State private var error: Bool = true
    @FocusState private var isFocused: Bool
    
    let step: Int = 1
    
    var body: some View {
        GeometryReader { _ in
            VStack(alignment: .leading, spacing: 0) {
                progressBar
                    .padding(.top, 56)
                
                Text("닉네임을 입력해 주세요")
                    .customFont(.title3b)
                    .padding(.top, 32)
                
                NicknameTextField(text: $text, isError: $error)
                    .padding(.top, 28)
                    .focused($isFocused)
                    .onSubmit {
                        //TODO: 검색 API
                        hideKeyboard()
                    }
                
                Spacer()
                
                SpoonyButton(style: .primary, size: .xlarge, title: "다음", disabled: $error) {
                    // 네비게이션
                }
                .padding(.top, 443)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
            .background(.white)
            .onTapGesture {
                //TODO: 검색 API
                hideKeyboard()
            }
        }
    }
    
    private var progressBar: some View {
        ProgressView(value: 1.0/3 * Double(step))
            .frame(height: 4.adjustedH)
            .progressViewStyle(.linear)
            .tint(.main400)
            .animation(.easeInOut, value: step)
    }
}

#Preview {
    NicknameStepView()
}

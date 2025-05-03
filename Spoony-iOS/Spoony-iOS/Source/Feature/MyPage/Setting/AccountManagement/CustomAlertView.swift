//
//  CustomAlertView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 5/3/25.
//

import SwiftUI

struct CustomAlertView: View {
    let title: String
    let cancelTitle: String
    let confirmTitle: String
    let cancelAction: () -> Void
    let confirmAction: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Text(title)
                    .customFont(.body1b)
                    .foregroundColor(.spoonBlack)
                    .padding(.top, 40)
                
                HStack(spacing: 12) {
                    // 취소 버튼
                    Button(action: cancelAction) {
                        Text(cancelTitle)
                            .customFont(.body2b)
                            .foregroundColor(.gray600)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48.adjustedH)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray0)
                            )
                    }
                    
                    // 확인 버튼
                    Button(action: confirmAction) {
                        Text(confirmTitle)
                            .customFont(.body2b)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44.adjustedH)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.spoonBlack)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .frame(width: UIScreen.main.bounds.width - 40)
            .background(Color.white)
            .cornerRadius(16)
        }
    }
}

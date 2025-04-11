//
//  SpoonDrawPopupView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/4/25.
//

import SwiftUI

struct SpoonDrawPopupView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            if isPresented {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isPresented = false
                    }
            }
            
            VStack(spacing: 0) {
                // 닫기 버튼 영역
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(.icCloseGray400)
                            .padding(.top, 15)
                            .padding(.trailing, 20)
                    }
                }
                
                Text("오늘의 스푼 뽑기")
                    .font(.title1)
                    .padding(.top, 0)
                
                Text("'스푼 뽑기' 버튼을 누르면\n오늘의 스폰을 획득할 수 있어요.")
                    .font(.body2sb)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray600)
                    .padding(.top, 16)
                
                //TODO: 로띠
                Rectangle()
                    .aspectRatio(1, contentMode: .fit)
                    .padding(.horizontal, 36)
                    .padding(.vertical, 20)
            
                SpoonyButton(
                    style: .primary,
                    size: .medium,
                    title: "스푼 뽑기",
                    disabled: .constant(true)
                ) {
                    //TODO: 스폰 뽑기 버튼 액션 추가
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color.white)
            .cornerRadius(16)
            .padding(.horizontal, 36)
        }
    }
}

#Preview {
    SpoonDrawPopupView(isPresented: .constant(true))
}

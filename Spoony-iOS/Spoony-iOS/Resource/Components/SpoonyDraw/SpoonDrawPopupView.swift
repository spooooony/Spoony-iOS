//
//  SpoonDrawPopupView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/4/25.
//

import SwiftUI

extension View {
    func height(_ height: CGFloat) -> some View {
        self.frame(height: height)
    }
}

struct SpoonDrawPopupView: View {
    @Binding var isPresented: Bool
    var body: some View {
        ZStack {
            // 배경 딤 처리
            if isPresented {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isPresented = false
                    }
            }
            
            // 팝업 내용
            VStack(spacing: 0) {
                // 닫기 버튼 영역
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .padding(.top, 16)
                            .padding(.trailing, 16)
                    }
                }
                
                // 제목
                Text("오늘의 스폰 뽑기")
                    .font(.system(size: 18, weight: .bold))
                    .padding(.top, 8)
                
                // 설명 텍스트
                Text("스폰 뽑기 버튼을 누르면\n오늘의 스폰을 획득할 수 있어요.")
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                
                // 체크보드 이미지 영역 (그레이 체크무늬 영역)
                Rectangle()
                   
                    .aspectRatio(1, contentMode: .fit)
                    .padding(.horizontal, 36)
                    .padding(.vertical, 20)
                
                // 버튼
                Button(action: {
                    // 스폰 뽑기 버튼 액션
                }) {
                    Text("스폰 뽑기")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.orange)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 36)
                .padding(.bottom, 24)
            }
            .background(Color.white)
            .cornerRadius(12)
            .height(303)
            .padding(.horizontal, 36)
            .opacity(isPresented ? 1 : 0)
            .scaleEffect(isPresented ? 1 : 0.5)
            .animation(.spring(), value: isPresented)
        }
    }
}

#Preview {
    SpoonDrawPopupView(isPresented: .constant(true))
}

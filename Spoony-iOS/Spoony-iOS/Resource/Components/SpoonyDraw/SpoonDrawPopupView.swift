//
//  SpoonDrawPopupView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/4/25.
//

import SwiftUI

struct SpoonDrawPopupView: View {
    @Binding var isPresented: Bool
    var onDrawSpoon: () -> Void
    
    let isDrawing: Bool
    let drawnSpoon: SpoonDrawResponse?
    let errorMessage: String?
    
    var body: some View {
        ZStack {
            if isPresented {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        if !isDrawing && (drawnSpoon != nil || errorMessage != nil) {
                            isPresented = false
                        }
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
                
                Text("'스푼 뽑기' 버튼을 누르면\n오늘의 스푼을 획득할 수 있어요.")
                    .font(.body2sb)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray600)
                    .padding(.top, 16)
                
                // 로띠 영역 또는 스푼 이미지 영역
                ZStack {
                    Rectangle()
                        .aspectRatio(1, contentMode: .fit)
                        .padding(.horizontal, 36)
                        .padding(.vertical, 20)
                        .foregroundColor(.gray100)
                        
                    if isDrawing {
                        // 로딩 상태
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(2.0)
                            
                            Text("스푼을 뽑는 중...")
                                .font(.body1sb)
                                .foregroundColor(.gray500)
                        }
                    } else if let spoon = drawnSpoon {
                        // 스푼 뽑기 성공 상태
                        VStack {
                            Image("ic_spoon_main")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                            
                            Text("+\(spoon.spoonType.spoonAmount) 스푼")
                                .font(.title3sb)
                                .foregroundStyle(.main400)
                                .padding(.top, 16)
                        }
                    } else if let error = errorMessage {
                        // 에러 상태
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.circle")
                                .font(.system(size: 40))
                                .foregroundColor(.gray400)
                            
                            Text("스푼 뽑기 실패")
                                .font(.title3sb)
                                .foregroundColor(.gray600)
                            
                            Text(error.contains("이미 스푼 뽑기를 진행한 사용자")
                                 ? "오늘 이미 스푼을 뽑았어요!\n내일 다시 시도해주세요."
                                 : "스푼 뽑기에 실패했어요.\n다시 시도해주세요.")
                                .font(.body2m)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray400)
                        }
                    } else {
                        // 초기 상태
                        Image("ic_spoon_main")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .opacity(0.6)
                    }
                }
            
                SpoonyButton(
                    style: .primary,
                    size: .medium,
                    title: getButtonTitle(),
                    isIcon: false,
                    disabled: .constant(isDrawing)
                ) {
                    if drawnSpoon != nil || errorMessage != nil {
                        isPresented = false
                    } else if !isDrawing {
                        onDrawSpoon()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color.white)
            .cornerRadius(16)
            .padding(.horizontal, 36)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    private func getButtonTitle() -> String {
        if drawnSpoon != nil {
            return "확인"
        } else if errorMessage != nil {
            return "닫기"
        } else if isDrawing {
            return "뽑는 중..."
        } else {
            return "스푼 뽑기"
        }
    }
}

#Preview {
    SpoonDrawPopupView(
        isPresented: .constant(true),
        onDrawSpoon: {},
        isDrawing: false,
        drawnSpoon: nil,
        errorMessage: nil
    )
}

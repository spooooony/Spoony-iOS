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
    
    @State private var isLoading = false
    @State private var drawnSpoons: Int? = nil
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea(.all)
                .onTapGesture {
                    if drawnSpoons != nil {
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
                
                Text("'스푼 뽑기' 버튼을 누르면\n오늘의 스푼을 획득할 수 있어요.")
                    .font(.body2sb)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray600)
                    .padding(.top, 16)
                
                ZStack {
                    Rectangle()
                        .fill(Color.gray100)
                        .aspectRatio(1, contentMode: .fit)
                        .padding(.horizontal, 36)
                        .padding(.vertical, 20)
                    
                    if let spoons = drawnSpoons {
                        VStack {
                            Image("ic_spoon_main")
                                .resizable()
                                .frame(width: 80, height: 80)
                            
                            Text("+\(spoons) 스푼")
                                .font(.title3sb)
                                .foregroundStyle(.main400)
                                .padding(.top, 16)
                        }
                    } else if isLoading {
                        ProgressView()
                            .scaleEffect(2.0)
                    }
                }
            
                SpoonyButton(
                    style: .primary,
                    size: .medium,
                    title: drawnSpoons != nil ? "확인" : "스푼 뽑기",
                    disabled: .constant(isLoading)
                ) {
                    if drawnSpoons != nil {
                        isPresented = false
                    } else {
                        drawSpoon()
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
    
    private func drawSpoon() {
        isLoading = true
        
        //TODO: 스푼 뽑기 로직
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // 1~5개 사이 랜덤 스푼
            self.drawnSpoons = Int.random(in: 1...5)
            self.isLoading = false
            self.onDrawSpoon()
        }
    }
}

#Preview {
    SpoonDrawPopupView(isPresented: .constant(true), onDrawSpoon: {})
}

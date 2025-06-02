//
//  SpoonDrawPopupView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/4/25.
//

import SwiftUI
import Lottie

struct SpoonDrawPopupView: View {
    @Binding var isPresented: Bool
    var onDrawSpoon: () -> Void
    
    let isDrawing: Bool
    let drawnSpoon: SpoonDrawResponse?
    let errorMessage: String?
    
    @State private var showLottieScreen = false
    @State private var showResultScreen = false
    
    var body: some View {
        ZStack {
            if isPresented {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        if !isDrawing && !showLottieScreen {
                            isPresented = false
                        }
                    }
            }
            
            if showLottieScreen {
                lottieOnlyView
            } else if showResultScreen {
                resultView
            } else {
                initialPopupView
            }
        }
        .onChange(of: isDrawing) { oldValue, newValue in
            if newValue && !oldValue {
                withAnimation(.easeInOut(duration: 0.1)) {
                    showLottieScreen = true
                }
            }
        }
        
        .onDisappear {
            resetStates()
        }
    }
    
    private var initialPopupView: some View {
        VStack(spacing: 0) {
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
            
            Text("출석체크 이벤트")
                .font(.title1)
                .padding(.top, 0)
            
            Text("'스푼 뽑기' 버튼을 누르면\n오늘의 스푼을 획득할 수 있어요.")
                .font(.body2m)
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray600)
                .padding(.top, 16)
      
            VStack(spacing: 2) {
                Image("iOS_Image_Pick")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 263, height: 200)
            }
            
            SpoonyButton(
                style: .secondary,
                size: .medium,
                title: "스푼 뽑기",
                isIcon: false,
                disabled: .constant(false)
            ) {
                onDrawSpoon()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .cornerRadius(16)
        .padding(.horizontal, 36)
        .transition(.opacity.combined(with: .scale))
    }
    
    private var lottieOnlyView: some View {
        VStack {
            Text("스푼을 뽑고있어요...")
                .font(.body1sb)
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray900)
                .padding(.top, 40)
            
            LottieView(animation: .named("iOS_Lottie_Shake"))
                .playing(loopMode: .repeat(2))
                .animationSpeed(1.0)
                .frame(width: 303.adjusted, height: 240.adjustedH)
            
            Spacer()
        }
        .frame(width: 303.adjusted, height: 303.adjustedH)
        .background(Color.white)
        .cornerRadius(16)
        .transition(.opacity.combined(with: .scale))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                handleLottieCompleted()
            }
        }
    }
    
    private var resultView: some View {
        VStack(spacing: 0) {
            if let spoon = drawnSpoon {
                successTicketView(spoon: spoon)
            } 
        }
        .transition(.opacity.combined(with: .scale))
    }
    
    private func successTicketView(spoon: SpoonDrawResponse) -> some View {
        VStack(spacing: 0) {
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
            
            Text("\(spoon.spoonType.spoonName) 획득")
                .font(.title1)
                .padding(.top, 0)
            
            Text("축하해요!\n총 \(spoon.spoonType.spoonAmount)개의 스푼을 적립했어요.")
                .font(.body2m)
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray600)
                .padding(.vertical, 16)
      
            VStack(spacing: 2) {
                AsyncImage(url: URL(string: spoon.spoonType.spoonImage)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 263.adjusted, height: 200.adjustedH)
                } placeholder: {
                    
                    // TODO: 서버에서 값 날아오면 지우기
                    Image(.testImage1)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 263, height: 200)
                }
            }
            
            SpoonyButton(
                style: .secondary,
                size: .medium,
                title: "확인",
                isIcon: false,
                disabled: .constant(false)
            ) {
                isPresented = false
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .cornerRadius(16)
        .padding(.horizontal, 36)
        .transition(.opacity.combined(with: .scale))
    }
    
    private func handleLottieCompleted() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showLottieScreen = false
            showResultScreen = true
        }
    }
    
    private func resetStates() {
        showLottieScreen = false
        showResultScreen = false
    }
}

#Preview {
    SpoonDrawPopupView(
        isPresented: .constant(true),
        onDrawSpoon: {},
        isDrawing: false,
        drawnSpoon: SpoonDrawResponse(
            drawId: 34,
            spoonType: SpoonType(
                spoonTypeId: 1,
                spoonName: "tea",
                spoonAmount: 1,
                probability: 40,
                spoonImage: "test_image"
            ),
            localDate: "2025-06-01",
            weekStartDate: "2025-05-26",
            createdAt: "2025-06-01T13:45:54.81992"
        ),
        errorMessage: nil
    )
}

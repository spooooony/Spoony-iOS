//
//  BottomSheetEmptyItem.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/18/25.
//

import SwiftUI

struct FixedBottomSheetView: View {
    private let screenHeight = UIScreen.main.bounds.height
    @State private var offset: CGFloat = 0
    @GestureState private var isDragging: Bool = false
    
    private let fixedHeight: CGFloat
    private let headerHeight: CGFloat = 60
    
    init() {
        self.fixedHeight = UIScreen.main.bounds.height * 0.5
    }
    
    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 0) {
                // 핸들바 영역
                VStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 36, height: 5)
                        .padding(.top, 10)
                    
                    Text("타이틀")
                        .font(.system(size: 18, weight: .semibold))
                        .padding(.bottom, 8)
                }
                .frame(height: headerHeight)
                .background(.white)
                
                Spacer()
            }
            .frame(height: fixedHeight)
            .frame(maxWidth: .infinity)
            .background(.white)
            .cornerRadius(10, corners: [.topLeft, .topRight])
            .offset(y: screenHeight - fixedHeight + offset)
            .gesture(
                DragGesture()
                    .updating($isDragging) { value, state, _ in
                        state = true
                    }
                    .onChanged { value in
                        // 드래그 거리가 일정 이상일 때만 offset 적용
                        let dragDistance = value.translation.height
                        let threshold: CGFloat = 100 // 드래그 임계값
                        
                        if dragDistance > threshold {
                            offset = dragDistance - threshold
                        } else if dragDistance < -threshold {
                            offset = dragDistance + threshold
                        } else {
                            offset = 0
                        }
                    }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            offset = 0
                        }
                    }
            )
        }
        .ignoresSafeArea()
    }
}

#Preview {
    FixedBottomSheetView()
}

//
//  CustomBottomSheet.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/12/25.
//

import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                               byRoundingCorners: corners,
                               cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct CustomBottomSheet<Content: View>: View {
    let style: BottomSheetStyle
    let content: Content
    @Binding var isPresented: Bool
    @State private var offset: CGFloat = 0
    @GestureState private var isDragging: Bool = false
    
    private var maxHeight: CGFloat { BottomSheetStyle.full.height }
    private var halfHeight: CGFloat { BottomSheetStyle.half.height }
    private var minHeight: CGFloat { BottomSheetStyle.minimal.height }
    
    private var currentHeight: CGFloat {
        maxHeight - offset
    }
     
    init(style: BottomSheetStyle, isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.style = style
        self._isPresented = isPresented
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray)
                        .frame(width: 40, height: 5)
                        .padding(.top, 8)
                    
                    Text("타이틀")
                        .font(.system(size: 18, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding()
                    
                    if currentHeight > minHeight {
                        content
                            .frame(maxHeight: .infinity)
                    }
                }
                .frame(height: currentHeight)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .gesture(
                    DragGesture()
                        .updating($isDragging) { value, state, _ in
                            state = true
                        }
                        .onChanged { value in
                            let translation = value.translation.height
                            let newOffset = max(0, min(maxHeight - minHeight, offset + translation))
                            withAnimation(.interactiveSpring()) {
                                offset = newOffset
                            }
                        }
                        .onEnded { value in
                            let velocity = value.predictedEndLocation.y - value.location.y
                            
                            withAnimation(.interpolatingSpring(
                                mass: 1.0,
                                stiffness: 200,
                                damping: 25,
                                initialVelocity: 0
                            )) {
                                if velocity < -100 {
                                    // 빠르게 위로 스와이프
                                    if currentHeight < halfHeight {
                                        offset = maxHeight - halfHeight  // half로
                                    } else {
                                        offset = 0  // full로
                                    }
                                } else if velocity > 100 {
                                    // 빠르게 아래로 스와이프
                                    if currentHeight > halfHeight {
                                        offset = maxHeight - halfHeight  // half로
                                    } else {
                                        offset = maxHeight - minHeight  // minimal로
                                    }
                                } else {
                                    // 일반적인 드래그
                                    if currentHeight > (maxHeight + halfHeight) / 2 {
                                        offset = 0  // full로
                                    } else if currentHeight > (halfHeight + minHeight) / 2 {
                                        offset = maxHeight - halfHeight  // half로
                                    } else {
                                        offset = maxHeight - minHeight  // minimal로
                                    }
                                }
                            }
                        }
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .ignoresSafeArea()
    }
}

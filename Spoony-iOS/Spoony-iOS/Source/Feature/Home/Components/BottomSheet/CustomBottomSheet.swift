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
    @State private var currentHeight: CGFloat
    @State private var dragOffset: CGFloat = 0
    
    @GestureState private var isDragging: Bool = false
    @State private var velocity: CGFloat = 0
    
    init(style: BottomSheetStyle, isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.style = style
        self._isPresented = isPresented
        self.content = content()
        self._currentHeight = State(initialValue: style.height)
    }
    
    private var maxHeight: CGFloat {
        BottomSheetStyle.full.height
    }
    
    private var minHeight: CGFloat {
        BottomSheetStyle.minimal.height
    }
    
    private func handleDragGesture(value: DragGesture.Value) {
        let verticalVelocity = value.predictedEndLocation.y - value.location.y
        
        if style == .button {
            if value.translation.height > 30 || verticalVelocity > 100 {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.8, blendDuration: 0)) {
                    dragOffset = 0
                    isPresented = false
                }
            } else {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.8, blendDuration: 0)) {
                    dragOffset = 0
                }
            }
            return
        }
        
        let newHeight = currentHeight - value.translation.height
        let velocityThreshold: CGFloat = 300
        
        withAnimation(.spring(response: 0.2, dampingFraction: 0.8, blendDuration: 0)) {
            if verticalVelocity > velocityThreshold {
                // 빠르게 아래로 스와이프
                if currentHeight <= BottomSheetStyle.half.height {
                    isPresented = false
                } else {
                    currentHeight = BottomSheetStyle.half.height
                }
            } else if verticalVelocity < -velocityThreshold {
                // 빠르게 위로 스와이프
                currentHeight = BottomSheetStyle.full.height
            } else {
                // 일반적인 드래그
                if value.translation.height > 0 {
                    if newHeight < BottomSheetStyle.minimal.height + 50 {
                        isPresented = false
                    } else if newHeight < BottomSheetStyle.half.height {
                        currentHeight = BottomSheetStyle.minimal.height
                    } else if newHeight < BottomSheetStyle.full.height {
                        currentHeight = BottomSheetStyle.half.height
                    }
                } else {
                    if newHeight > BottomSheetStyle.half.height + 50 {
                        currentHeight = BottomSheetStyle.full.height
                    } else if newHeight > BottomSheetStyle.minimal.height + 50 {
                        currentHeight = BottomSheetStyle.half.height
                    } else {
                        currentHeight = BottomSheetStyle.minimal.height
                    }
                }
            }
            dragOffset = 0
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                if isPresented {
                    VStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray)
                            .frame(width: 40, height: 5)
                            .padding(.top, 8)
                        
                        content
                    }
                    .frame(height: currentHeight - dragOffset)
                    .background(Color.white)
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .gesture(
                        DragGesture()
                            .updating($isDragging) { value, state, _ in
                                state = true
                            }
                            .onChanged({ value in
                                withAnimation(.interactiveSpring()) {
                                    if style == .button {
                                        if value.translation.height > 0 {
                                            dragOffset = min(value.translation.height, 100)
                                        }
                                    } else {
                                        let newHeight = currentHeight - value.translation.height
                                        if newHeight >= minHeight && newHeight <= maxHeight {
                                            dragOffset = value.translation.height
                                        }
                                    }
                                }
                            })
                            .onEnded(handleDragGesture)
                    )
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        )
                    )
                    .offset(y: -geometry.safeAreaInsets.bottom)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea()
        }
        .animation(
            isDragging ? .interactiveSpring() : .spring(response: 0.2, dampingFraction: 0.8, blendDuration: 0),
            value: currentHeight
        )
        .animation(.spring(response: 0.2, dampingFraction: 0.8, blendDuration: 0), value: isPresented)
    }
}

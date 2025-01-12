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
        if style == .button {
            if value.translation.height > 30 {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    dragOffset = 0
                    isPresented = false
                }
            } else {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    dragOffset = 0
                }
            }
            return
        }
        
        let newHeight = currentHeight - value.translation.height
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
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
                            .onChanged({ value in
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
                            })
                            .onEnded(handleDragGesture)
                    )
                    .transition(.move(edge: .bottom))
                    .offset(y: -geometry.safeAreaInsets.bottom)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea()
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0), value: isPresented)
        .animation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0), value: currentHeight)
    }
}

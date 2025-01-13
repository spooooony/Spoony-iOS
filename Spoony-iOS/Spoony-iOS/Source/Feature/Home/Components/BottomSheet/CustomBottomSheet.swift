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
    
    private var maxHeight: CGFloat { style.height }
    private var minHeight: CGFloat { BottomSheetStyle.minimal.height }
    
    init(style: BottomSheetStyle, isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.style = style
        self._isPresented = isPresented
        self.content = content()
        self._currentHeight = State(initialValue: style.height)
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
                        
                        Text("타이틀")
                            .font(.system(size: 18, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding()
                        
                        if currentHeight > minHeight {
                            content
                        }
                    }
                    .frame(height: max(currentHeight - dragOffset, minHeight))
                    .background(Color.white)
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .updating($isDragging) { _, state, _ in
                                state = true
                            }
                            .onChanged { value in
                                let newHeight = currentHeight - value.translation.height
                                if newHeight >= minHeight && newHeight <= maxHeight {
                                    dragOffset = value.translation.height
                                }
                            }
                            .onEnded(handleDragGesture)
                    )
                    .transition(.move(edge: .bottom))
                    .offset(y: -geometry.safeAreaInsets.bottom)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea()
        }
        .animation(nil, value: dragOffset)
        .animation(
            isDragging ? nil : .interpolatingSpring(stiffness: 300, damping: 30),
            value: currentHeight
        )
    }
    
    private func handleDragGesture(value: DragGesture.Value) {
        let verticalVelocity = value.predictedEndLocation.y - value.location.y
        let newHeight = currentHeight - value.translation.height
        
        if abs(verticalVelocity) > 300 {
            if verticalVelocity > 0 {
                currentHeight = minHeight
            } else {
                currentHeight = maxHeight
            }
        } else {
            if value.translation.height > 0 {
                if newHeight < minHeight + 50 {
                    currentHeight = minHeight
                } else if newHeight < BottomSheetStyle.half.height {
                    currentHeight = minHeight
                } else {
                    currentHeight = BottomSheetStyle.half.height
                }
            } else {
                if newHeight > BottomSheetStyle.half.height + 50 {
                    currentHeight = maxHeight
                } else {
                    currentHeight = BottomSheetStyle.half.height
                }
            }
        }
        dragOffset = 0
    }
}

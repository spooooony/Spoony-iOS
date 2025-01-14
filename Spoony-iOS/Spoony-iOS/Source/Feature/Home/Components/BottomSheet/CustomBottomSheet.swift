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
    @Binding var isPresented: Bool
    let content: Content
    
    @GestureState private var translation: CGFloat = 0
    @State private var offsetY: CGFloat = 0
    
    private let headerHeight: CGFloat = 60  // 핸들바와 타이틀의 전체 높이
    
    init(style: BottomSheetStyle, isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.style = style
        self._isPresented = isPresented
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // 배경 오버레이
                if isPresented {
                    Color.black
                        .opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            isPresented = false
                        }
                }
                
                VStack(spacing: 0) {
                    // 고정된 헤더 영역
                    VStack(spacing: 8) {
                        // 핸들바
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 36, height: 5)
                            .padding(.top, 10)
                        
                        // 타이틀
                        Text("타이틀")
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.bottom, 8)
                    }
                    .frame(height: headerHeight)
                    .background(Color.white)
                    .zIndex(1)  // 헤더를 항상 위에 표시
                    
                    // 스크롤 가능한 컨텐츠
                    content
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white)
                }
                .frame(height: style.height - offsetY)
                .background(Color.white)
                .cornerRadius(10)
                .offset(y: max(geometry.size.height - style.height + offsetY + translation, 0))
                .animation(.interactiveSpring(), value: isPresented)
                .gesture(
                    DragGesture()
                        .updating($translation) { value, state, _ in
                            state = value.translation.height
                        }
                        .onEnded { value in
                            let snapDistance = style.height * 0.25
                            let dragDistance = value.translation.height
                            
                            if dragDistance > snapDistance {
                                isPresented = false
                            } else {
                                offsetY = 0
                            }
                        }
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
    }
}

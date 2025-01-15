//
//  BottomSheetList.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/12/25.
//

import SwiftUI

struct BottomSheetListItem: View {
    let title: String
    let subTitle: String
    let cellTitle: String
    let hasChip: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .lineLimit(1)
                    if hasChip {
                        Text("chip")
                            .font(.system(size: 12))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(Color.red)
                            .cornerRadius(12)
                    }
                }
                
                Text(subTitle)
                    .font(.caption1m)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                Text(cellTitle)
                    .font(.body1b)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            .layoutPriority(1)

            //Todo: 실제 이미지로 교체
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.1))
                .frame(width: 98.adjusted, height: 98.adjusted)
                .layoutPriority(0)
        }
        .padding(.horizontal, 16)
        .frame(height: 120.adjusted)
    }
}

struct BottomSheetListView: View {
    @State private var currentStyle: BottomSheetStyle = .minimal
    @State private var offset: CGFloat = 0
    @GestureState private var isDragging: Bool = false
    
    // 각 상태별 높이값을 저장
    private var snapPoints: [CGFloat] {
        [
            BottomSheetStyle.minimal.height,
            BottomSheetStyle.half.height,
            BottomSheetStyle.full.height
        ]
    }
    
    private func getClosestSnapPoint(to offset: CGFloat) -> BottomSheetStyle {
        let screenHeight = UIScreen.main.bounds.height
        let currentHeight = screenHeight - offset
        
        // 현재 높이와 각 스냅 포인트와의 거리를 계산
        let distances = [
            (abs(currentHeight - BottomSheetStyle.minimal.height), BottomSheetStyle.minimal),
            (abs(currentHeight - BottomSheetStyle.half.height), BottomSheetStyle.half),
            (abs(currentHeight - BottomSheetStyle.full.height), BottomSheetStyle.full)
        ]
        
        // 가장 가까운 스냅 포인트 반환
        return distances.min(by: { $0.0 < $1.0 })?.1 ?? .minimal
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
                .frame(height: 60)
                .background(Color.white)
                
                // 컨텐츠 영역
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(0..<5) { _ in
                            BottomSheetListItem(
                                title: "상호명",
                                subTitle: "주소",
                                cellTitle: "제목 셀",
                                hasChip: true
                            )
                            Divider()
                        }
                    }
                }
                .disabled(currentStyle == .minimal)
            }
            .frame(maxHeight: .infinity)
            .background(Color.white)
            .cornerRadius(10, corners: [.topLeft, .topRight])
            .offset(y: UIScreen.main.bounds.height - currentStyle.height + offset)
            .gesture(
                DragGesture()
                    .updating($isDragging) { _, state, _ in
                        state = true
                    }
                    .onChanged { value in
                        let translation = value.translation.height
                        
                        if currentStyle == .full && translation < 0 {
                            offset = 0
                        } else {
                            offset = translation
                        }
                    }
                    .onEnded { value in
                        let translation = value.translation.height
                        let velocity = value.predictedEndTranslation.height - translation
                        
                        // 속도가 빠른 경우 (빠른 스와이프)
                        if abs(velocity) > 500 {
                            if velocity > 0 { // 아래로 빠른 스와이프
                                switch currentStyle {
                                case .full: currentStyle = .half
                                case .half: currentStyle = .minimal
                                case .minimal: break
                                }
                            } else { // 위로 빠른 스와이프
                                switch currentStyle {
                                case .full: break
                                case .half: currentStyle = .full
                                case .minimal: currentStyle = .half
                                }
                            }
                        } else {
                            // 일반적인 드래그의 경우
                            let screenHeight = UIScreen.main.bounds.height
                            let currentOffset = screenHeight - currentStyle.height + translation
                            currentStyle = getClosestSnapPoint(to: currentOffset)
                        }
                        
                        // 오프셋 초기화
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            offset = 0
                        }
                    }
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentStyle)
        }
    }
}

#Preview {
    Home()
}

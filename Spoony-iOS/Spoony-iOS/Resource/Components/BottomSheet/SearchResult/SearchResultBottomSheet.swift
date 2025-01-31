//
//  SearchLocationBottomSheetView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/30/25.
//

import SwiftUI

struct SearchLocationBottomSheetView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var currentStyle: BottomSheetStyle = .minimal
    @State private var offset: CGFloat = 0
    @GestureState private var isDragging: Bool = false
    @State private var scrollOffset: CGFloat = 0
    @State private var isScrollEnabled: Bool = false
    
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
        
        let distances = [
            (abs(currentHeight - BottomSheetStyle.minimal.height), BottomSheetStyle.minimal),
            (abs(currentHeight - BottomSheetStyle.half.height), BottomSheetStyle.half),
            (abs(currentHeight - BottomSheetStyle.full.height), BottomSheetStyle.full)
        ]
        
        return distances.min(by: { $0.0 < $1.0 })?.1 ?? .minimal
    }
    
    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 0) {
                // 핸들바 영역
                VStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray200)
                        .frame(width: 24.adjusted, height: 2.adjustedH)
                        .padding(.top, 10)
                    
                    HStack(spacing: 4) {
                        Text("이 지역의 찐맛집")
                            .customFont(.body2b)
                        Text("\(viewModel.pickList.count)")
                            .customFont(.body2b)
                            .foregroundColor(.gray500)
                    }
                    .padding(.bottom, 8)
                }
                .frame(height: 60.adjustedH)
                .background(.white)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.pickList, id: \.placeId) { pickCard in
                                SearchLocationCardItem(pickCard: pickCard.toSearchLocationResult())
                                    .background(Color.white)
                                    .onTapGesture {
                                        if currentStyle == .half {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                currentStyle = .full
                                                isScrollEnabled = true
                                            }
                                        }
                                        viewModel.fetchFocusedPlace(placeId: pickCard.placeId)
                                    }
                            }
                        }
                        Color.clear.frame(height: 90.adjusted)
                    }
                }
                .coordinateSpace(name: "scrollView")
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            if currentStyle == .half && value.translation.height < 0 {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    currentStyle = .full
                                    isScrollEnabled = true
                                }
                            }
                        }
                )
                .disabled(!isScrollEnabled)
            }
            .frame(maxHeight: .infinity)
            .background(.white)
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
                        
                        if abs(velocity) > 500 {
                            if velocity > 0 {
                                switch currentStyle {
                                case .full:
                                    currentStyle = .half
                                    isScrollEnabled = false
                                case .half:
                                    currentStyle = .minimal
                                case .minimal: break
                                }
                            } else {
                                switch currentStyle {
                                case .full: break
                                case .half:
                                    currentStyle = .full
                                    isScrollEnabled = true
                                case .minimal:
                                    currentStyle = .half
                                }
                            }
                        } else {
                            let screenHeight = UIScreen.main.bounds.height
                            let currentOffset = screenHeight - currentStyle.height + translation
                            let newStyle = getClosestSnapPoint(to: currentOffset)
                            currentStyle = newStyle
                            isScrollEnabled = (newStyle == .full)
                        }
                        
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            offset = 0
                        }
                    }
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentStyle)
            .onChange(of: currentStyle) { _, newStyle in
                isScrollEnabled = (newStyle == .full)
            }
        }
    }
}

//
//  SearchLocationBottomSheetView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/30/25.
//

import SwiftUI

struct SearchLocationBottomSheetView: View {
    @StateObject var viewModel: HomeViewModel
    @State private var currentStyle: BottomSheetStyle = .minimal
    @State private var offset: CGFloat = 0
    @GestureState private var isDragging: Bool = false
    @State private var scrollOffset: CGFloat = 0
    @State private var isScrollEnabled: Bool = false
    
    // snapPoints를 computed property 대신 상수로 변경
    private let snapPoints: [CGFloat] = [
        BottomSheetStyle.minimal.height,
        BottomSheetStyle.half.height,
        BottomSheetStyle.full.height
    ]
    
    // 헤더 뷰를 별도로 분리
    private var headerView: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray200)
                .frame(width: 24.adjusted, height: 2.adjustedH)
                .padding(.top, 10)
            
            HStack(spacing: 4) {
                Text("검색 결과")
                    .customFont(.body2b)
                Text("\(viewModel.pickList.count)")
                    .customFont(.body2b)
                    .foregroundColor(.gray500)
            }
            .padding(.bottom, 8)
        }
        .frame(height: 60.adjustedH)
        .background(.white)
    }
    
    // 컨텐츠 뷰를 별도로 분리
    private var contentView: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.pickList, id: \.placeId) { pickCard in
                    SearchLocationCardItem(pickCard: pickCard.toSearchLocationResult())  // 변환
                        .background(Color.white)
                        .onTapGesture {
                            handleCardTap(pickCard: pickCard)
                        }
                }
                Color.clear.frame(height: 90.adjusted)
            }
        }
        .coordinateSpace(name: "scrollView")
        .simultaneousGesture(
            DragGesture().onChanged(handleDrag)
        )
        .disabled(!isScrollEnabled)
    }
    
    // 탭 핸들러를 별도 메서드로 분리
    private func handleCardTap(pickCard: PickListCardResponse) {
        if currentStyle == .half {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                currentStyle = .full
                isScrollEnabled = true
            }
        }
        viewModel.fetchFocusedPlace(placeId: pickCard.placeId)
    }
    
    // 드래그 핸들러를 별도 메서드로 분리
    private func handleDrag(value: DragGesture.Value) {
        if currentStyle == .half && value.translation.height < 0 {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                currentStyle = .full
                isScrollEnabled = true
            }
        }
    }
    
    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 0) {
                headerView
                contentView
            }
            .frame(maxHeight: .infinity)
            .background(.white)
            .cornerRadius(10, corners: [.topLeft, .topRight])
            .offset(y: UIScreen.main.bounds.height - currentStyle.height + offset)
        }
    }
}

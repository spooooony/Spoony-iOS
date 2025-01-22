//
//  BottomSheetList.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/12/25.
//

import SwiftUI

struct BottomSheetListItem: View {
    let pickCard: PickListCardResponse
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(pickCard.placeName)
                        .customFont(.body1b)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    // 카테고리 칩
                    HStack(spacing: 4) {
                        // 카테고리 아이콘
                        AsyncImage(url: URL(string: pickCard.categoryColorResponse.iconUrl)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                            default:
                                Color.clear
                                    .frame(width: 16, height: 16)
                            }
                        }
                        
                        Text(pickCard.categoryColorResponse.categoryName)
                            .customFont(.caption1m)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: pickCard.categoryColorResponse.iconBackgroundColor))
                    .foregroundColor(Color(hex: pickCard.categoryColorResponse.iconTextColor))
                    .cornerRadius(12)
                }
                
                Text(pickCard.placeAddress)
                    .customFont(.caption1m)
                    .foregroundColor(.gray600)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text(pickCard.postTitle)
                    .customFont(.caption1m)
                    .foregroundColor(.spoonBlack)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 12)
                    .background(.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.gray0), lineWidth: 1)
                    )
                    .shadow(
                        color: Color(.gray0),
                        radius: 16,
                        x: 0,
                        y: 2
                    )
                    .layoutPriority(1)
            }
            // 이미지
            AsyncImage(url: URL(string: pickCard.photoUrl)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    defaultPlaceholder
                case .empty:
                    defaultPlaceholder
                @unknown default:
                    defaultPlaceholder
                }
            }
            .frame(width: 98.adjusted, height: 98.adjusted)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .layoutPriority(0)
        }
        .padding(.horizontal, 16)
        .frame(height: 120.adjusted)
    }
    
    private var defaultPlaceholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.1))
    }
}

struct BottomSheetListView: View {
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
                    
                    Text("타이틀")
                        .customFont(.body2b)
                        .padding(.bottom, 8)
                }
                .frame(height: 60.adjustedH)
                .background(.white)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.pickList, id: \.placeId) { pickCard in
                                BottomSheetListItem(pickCard: pickCard)
                                    .background(Color.white)
                                    .onTapGesture {
                                        if currentStyle == .half {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                currentStyle = .full
                                                isScrollEnabled = true
                                            }
                                        }
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

#Preview {
    BottomSheetListView(viewModel: HomeViewModel())
}

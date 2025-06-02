//
//  FlexibleListBottomSheet.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 2/10/25.
//

import SwiftUI

import ComposableArchitecture

struct FlexibleListBottomSheet: View {
    @ObservedObject var viewModel: HomeViewModel
    private let store: StoreOf<MapFeature>
    @State private var currentStyle: BottomSheetStyle = .half
    @State private var offset: CGFloat = 0
    @GestureState private var isDragging: Bool = false
    @State private var isScrollEnabled: Bool = false
    
    init(viewModel: HomeViewModel, store: StoreOf<MapFeature>) {
        self.viewModel = viewModel
        self.store = store
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray200)
                        .frame(width: 24.adjusted, height: 2.adjustedH)
                        .padding(.top, 10)
                    
                    HStack(spacing: 4) {
                        Text("\(store.userName)님의 찐맛집")
                            .customFont(.body2b)
                        Text("\(viewModel.pickList.count)")
                            .customFont(.body2b)
                            .foregroundColor(.gray500)
                    }
                    .padding(.bottom, 8)
                }
                .frame(height: 60.adjustedH)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        // Lint 오류로 인해 100자가 넘어도 무시하고 넘겨주세요!
                        ForEach(Array(viewModel.pickList.enumerated()), id: \.element.placeId) { _, pickCard in
                            BottomSheetListItem(pickCard: pickCard)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        currentStyle = .full
                                        isScrollEnabled = true
                                    }
                                    viewModel.fetchFocusedPlace(placeId: pickCard.placeId)
                                }
                        }
                        
                        if currentStyle == .full {
                            Color.clear.frame(height: 230.adjustedH)
                        }
                    }
                }
                .disabled(!isScrollEnabled)
            }
            .frame(maxHeight: .infinity)
            .background(Color.white)
            .cornerRadius(10, corners: [.topLeft, .topRight])
            .offset(y: geometry.size.height - currentStyle.height + offset)
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
                                    currentStyle = .full
                                    isScrollEnabled = false
                                case .half:
                                    currentStyle = .half
                                case .minimal:
                                    currentStyle = .minimal
                                    
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
                            let screenHeight = geometry.size.height
                            let currentOffset = screenHeight - currentStyle.height + translation
                            currentStyle = getClosestSnapPoint(to: currentOffset, in: geometry)
                            isScrollEnabled = (currentStyle == .full)
                        }
                        
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            offset = 0
                        }
                    }
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentStyle)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: offset)
        }
        .ignoresSafeArea()
    }
    
    private func getClosestSnapPoint(to offset: CGFloat, in geometry: GeometryProxy) -> BottomSheetStyle {
        let screenHeight = geometry.size.height
        let currentHeight = screenHeight - offset
        
        let distances = [
            (abs(currentHeight - BottomSheetStyle.minimal.height), BottomSheetStyle.minimal),
            (abs(currentHeight - BottomSheetStyle.half.height), BottomSheetStyle.half),
            (abs(currentHeight - BottomSheetStyle.full.height), BottomSheetStyle.full)
        ]
        
        return distances.min(by: { $0.0 < $1.0 })?.1 ?? .half
    }
}

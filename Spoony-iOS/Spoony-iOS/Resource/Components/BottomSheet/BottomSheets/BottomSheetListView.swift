//
//  BottomSheetListView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/11/25.
//

import SwiftUI
import ComposableArchitecture

struct BottomSheetListView: View {
    private let store: StoreOf<MapFeature>
    @Binding var currentStyle: BottomSheetStyle
    @Binding var bottomSheetHeight: CGFloat
    @State private var offset: CGFloat = 0
    @GestureState private var isDragging: Bool = false
    @State private var isScrollEnabled: Bool = false
    
    init(store: StoreOf<MapFeature>,
         currentStyle: Binding<BottomSheetStyle>,
         bottomSheetHeight: Binding<CGFloat>) {
        self.store = store
        self._currentStyle = currentStyle
        self._bottomSheetHeight = bottomSheetHeight
    }
    
    private func getClosestSnapPoint(to offset: CGFloat) -> BottomSheetStyle {
        let screenHeight = UIScreen.main.bounds.height
        let currentHeight = screenHeight - offset
        
        let distances = [
            (abs(currentHeight - BottomSheetStyle.minimal.height), BottomSheetStyle.minimal),
            (abs(currentHeight - BottomSheetStyle.half.height), BottomSheetStyle.half),
            (abs(currentHeight - BottomSheetStyle.full.height), BottomSheetStyle.full)
        ]
        
        return distances.min(by: { $0.0 < $1.0 })?.1 ?? .half
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // 핸들바 영역
                VStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray200)
                        .frame(width: 24.adjusted, height: 2.adjustedH)
                        .padding(.top, 10)
                    
                    HStack(spacing: 4) {
                        Text("\(store.userName)님의 찐맛집")
                            .customFont(.body2b)
                        Text("\(store.filteredPickList.count)")
                            .customFont(.body2b)
                            .foregroundColor(.gray500)
                    }
                    .padding(.bottom, 8)
                }
                .frame(height: 60.adjustedH)
                .background(Color.white)
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(store.filteredPickList, id: \.placeId) { pickCard in
                            BottomSheetListItem(pickCard: pickCard)
                                .background(Color.white)
                                .onTapGesture {
                                    store.send(.fetchFocusedPlace(placeId: pickCard.placeId))
                                }
                                .allowsHitTesting(true)
                        }
                        
                        if currentStyle == .full {
                            Color.clear.frame(height: 230.adjustedH)
                        }
                    }
                    .allowsHitTesting(true)
                }
                .scrollDisabled(currentStyle != .full)
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
                            bottomSheetHeight = currentStyle.height - translation
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
                            bottomSheetHeight = currentStyle.height
                        }
                    }
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentStyle)
            .onChange(of: currentStyle) { _, newStyle in
                isScrollEnabled = (newStyle == .full)
                bottomSheetHeight = newStyle.height
            }
            .onAppear {
                bottomSheetHeight = currentStyle.height
            }
        }
        .ignoresSafeArea()
    }
}

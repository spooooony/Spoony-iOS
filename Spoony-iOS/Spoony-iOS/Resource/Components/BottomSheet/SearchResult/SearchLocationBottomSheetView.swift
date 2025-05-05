//
//  SearchLocationBottomSheetView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 2/10/25.
//

import SwiftUI
import ComposableArchitecture

struct SearchLocationBottomSheetView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var currentStyle: BottomSheetStyle = .half
    private let store: StoreOf<MapFeature>
    private let locationTitle: String
    
    init(viewModel: HomeViewModel, store: StoreOf<MapFeature>, locationTitle: String = "") {
        self.viewModel = viewModel
        self.store = store
        self.locationTitle = locationTitle
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
                        Text(locationTitle)
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
                        ForEach(viewModel.pickList, id: \.placeId) { place in
                            BottomSheetListItem(pickCard: place)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        currentStyle = .full
                                    }
                                    viewModel.fetchFocusedPlace(placeId: place.placeId)
                                }
                        }
                        
                        if currentStyle == .full {
                            Color.clear.frame(height: 230.adjustedH)
                        }
                    }
                }
                .disabled(currentStyle == .half)
            }
            //            .frame(maxHeight: .infinity)
            //            .background(Color.white)
            //            .cornerRadius(10, corners: [.topLeft, .topRight])
            //            .offset(y: geometry.size.height - currentStyle.height(for: geometry.size.height) + viewModel.draggedHeight)
            //            .gesture(
            //                DragGesture()
            //                    .onChanged { value in
            //                        // HomeViewModel에 draggedHeight 속성 추가 필요
            //                        // viewModel.draggedHeight = value.translation.height
            //                    }
            //                    .onEnded { value in
            //                        let translation = value.translation.height
            //                        let velocity = value.predictedEndTranslation.height - translation
            //                        handleDragEnd(translation: translation, velocity: velocity, in: geometry)
            //                        // viewModel.draggedHeight = 0
            //                    }
            //            )
            //            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentStyle)
            //            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.draggedHeight)
            //        }
            //        .ignoresSafeArea()
        }
        //
        //    private func getClosestSnapPoint(to offset: CGFloat, in geometry: GeometryProxy) -> BottomSheetStyle {
        //        let screenHeight = geometry.size.height
        //        let currentHeight = screenHeight - offset
        //
        //        let distances = [
        //            (abs(currentHeight - BottomSheetStyle.minimal.height(for: screenHeight)), BottomSheetStyle.minimal),
        //            (abs(currentHeight - BottomSheetStyle.half.height(for: screenHeight)), BottomSheetStyle.half),
        //            (abs(currentHeight - BottomSheetStyle.full.height(for: screenHeight)), BottomSheetStyle.full)
        //        ]
        //
        //        return distances.min(by: { $0.0 < $1.0 })?.1 ?? .half
        //    }
        //
        //    private func handleDragEnd(translation: CGFloat, velocity: CGFloat, in geometry: GeometryProxy) {
        //        if abs(velocity) > 500 {
        //            handleVelocityBasedSnap(velocity: velocity)
        //        } else {
        //            let screenHeight = geometry.size.height
        //            let currentOffset = screenHeight - currentStyle.height(for: screenHeight) + translation
        //            currentStyle = getClosestSnapPoint(to: currentOffset, in: geometry)
        //        }
        //    }
        //
        //    private func handleVelocityBasedSnap(velocity: CGFloat) {
        //        if velocity > 0 {
        //            switch currentStyle {
        //            case .full:
        //                currentStyle = .full
        //            case .half:
        //                currentStyle = .half
        //            case .minimal:
        //                currentStyle = .minimal
        //
        //                break
        //            }
        //        } else {
        //            switch currentStyle {
        //                currentStyle = .minimal
        //            case .minimal:
        //                currentStyle = .half
        //            case .half:
        //                currentStyle = .full
        //            case .full:
        //                break
        //            }
        //        }
        //    }
    }
}

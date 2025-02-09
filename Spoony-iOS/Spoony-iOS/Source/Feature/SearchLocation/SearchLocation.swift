//
//  SearchLocation.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/30/25.
//

import SwiftUI
import FlexSheet

struct SearchLocation: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject private var viewModel: HomeViewModel
    @State private var selectedPlace: CardPlace?
    @State private var isLoading: Bool = true
    
    private let locationId: Int
    private let locationTitle: String
    
    init(locationId: Int, locationTitle: String) {
        self.locationId = locationId
        self.locationTitle = locationTitle
        _viewModel = StateObject(wrappedValue: HomeViewModel(service: DefaultHomeService()))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            if isLoading {
                ProgressView()
            } else {
                NMapView(viewModel: viewModel, selectedPlace: $selectedPlace)
                    .edgesIgnoringSafeArea(.all)
                    .onChange(of: viewModel.focusedPlaces) { _, newPlaces in
                        if !newPlaces.isEmpty {
                            selectedPlace = newPlaces[0]
                        }
                    }
                
                VStack(spacing: 0) {
                    CustomNavigationBar(
                        style: .locationTitle,
                        title: locationTitle,
                        onBackTapped: {
                            navigationManager.pop(2)
                        }
                    )
                    .frame(height: 56.adjusted)
                    Spacer()
                }
                
                Group {
                    if !viewModel.focusedPlaces.isEmpty {
                        PlaceCard(
                            places: viewModel.focusedPlaces,
                            currentPage: .constant(0)
                        )
                        .padding(.bottom, 12)
                        .transition(.move(edge: .bottom))
                        
                    } else {
                        SearchLocationBottomSheetView(viewModel: viewModel)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarHidden(true)
        .task {
            isLoading = true
            await viewModel.fetchLocationList(locationId: locationId)
            isLoading = false
        }
    }
}

struct SearchLocationBottomSheetView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var currentStyle: BottomSheetStyle = .half
    @State private var scrollOffset: CGFloat = 0
    @State private var lastContentOffset: CGFloat = 0
    @State private var isAtTop: Bool = true
    @GestureState private var isDragging: Bool = false
    @State private var firstVisibleItemIndex: Int = 0
    
    var body: some View {
        GeometryReader { geo in
            FlexibleBottomSheet(
                currentStyle: $currentStyle,
                style: .defaultFlex
            ) {
                VStack(spacing: 0) {
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
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    
                    ScrollView(showsIndicators: false) {
                        GeometryReader { geometry in
                            Color.clear.preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: geometry.frame(in: .named("scroll")).minY
                            )
                        }
                        .frame(height: 0)
                        
                        LazyVStack(spacing: 0) {
                            ForEach(Array(viewModel.pickList.enumerated()), id: \.element.placeId) { index, pickCard in
                                SearchLocationCardItem(pickCard: pickCard.toSearchLocationResult())
                                    .id(Int(index))
                                    .onAppear {
                                        if index == 0 {
                                            firstVisibleItemIndex = 0
                                        }
                                    }
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            currentStyle = .full
                                        }
                                        viewModel.fetchFocusedPlace(placeId: pickCard.placeId)
                                    }
                            }
                            
                            if currentStyle == .full {
                                Color.clear.frame(height: 90.adjusted)
                            }
                            
                            if currentStyle == .full {
                                Color.clear.frame(height: 90.adjusted)
                            }
                        }
                        
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                        if isDragging {
                            isAtTop = offset >= 0
                            scrollOffset = offset
                        }
                    }
                    .disabled(currentStyle == .half)
                }
                .background(Color.white)
            }
        }
    }
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

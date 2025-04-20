//
//  SearchLocation.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/30/25.
//

import SwiftUI
import ComposableArchitecture

struct SearchLocation: View {
    @StateObject private var viewModel: HomeViewModel
    @State private var selectedPlace: CardPlace?
    @State private var isLoading: Bool = true
    
    private let locationId: Int
    private let locationTitle: String
    private let store: StoreOf<MapFeature>
    
    init(
        locationId: Int,
        locationTitle: String,
        store: StoreOf<MapFeature>
    ) {
        self.locationId = locationId
        self.locationTitle = locationTitle
        self.store = store
        self._viewModel = StateObject(wrappedValue: HomeViewModel(service: DefaultHomeService()))
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
                        } else {
                            selectedPlace = nil
                        }
                    }
                
                VStack(spacing: 0) {
                    CustomNavigationBar(
                        style: .locationTitle,
                        title: locationTitle,
                        onBackTapped: {
                            store.send(.routToExploreTab)
                        }
                    )
                    .frame(height: 56.adjusted)
                    Spacer()
                }
                
//                Group {
//                    if !viewModel.focusedPlaces.isEmpty {
//                        PlaceCard(
//                            places: viewModel.focusedPlaces,
//                            currentPage: .constant(0)
//                        )
//                        .padding(.bottom, 12)
//                        .transition(.move(edge: .bottom))
//                    } else {
//                        if !viewModel.pickList.isEmpty {
//                            FlexibleListBottomSheet(viewModel: viewModel)
//                        } else {
//                            EmptyStateBottomSheet()
//                        }
//                    }
//                }
            }
        }
        .navigationBarHidden(true)
        .task {
            isLoading = true
            await viewModel.fetchLocationList(locationId: locationId)
            isLoading = false
        }
    }
}

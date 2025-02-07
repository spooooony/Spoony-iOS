//
//  SearchLocation.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/30/25.
//

import SwiftUI

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
                    .onChange(of: viewModel.focusedPlaces) { newPlaces in
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
                    }
//                    } else {
//                        SearchLocationBottomSheetView(viewModel: viewModel)
//                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            isLoading = true
            do {
                await viewModel.fetchLocationList(locationId: locationId)
                isLoading = false
            } catch {
                print("Failed to fetch data:", error)
                isLoading = false
            }
        }
    }
}

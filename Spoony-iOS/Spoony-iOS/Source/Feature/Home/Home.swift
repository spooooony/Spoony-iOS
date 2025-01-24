//
//  Home.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/2/25.
//

import SwiftUI


struct Home: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject private var viewModel = HomeViewModel(service: DefaultHomeService())
    @State private var isBottomSheetPresented = true
    @State private var searchText = ""
    @State private var selectedPlace: CardPlace?
    @State private var currentPage = 0
    @State private var spoonCount: Int = 0
    private let restaurantService: HomeServiceType
    
    init(restaurantService: HomeServiceType = DefaultHomeService()) {
        self.restaurantService = restaurantService
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            NMapView(viewModel: viewModel, selectedPlace: $selectedPlace)
                .edgesIgnoringSafeArea(.all)
                .onChange(of: viewModel.focusedPlaces) { _, newPlaces in
                    if !newPlaces.isEmpty {
                        selectedPlace = newPlaces[0]
                    }
                }
                .onChange(of: selectedPlace) { _, newPlace in
                    if newPlace == nil {
                        viewModel.clearFocusedPlaces()
                    }
                }
            
            VStack(spacing: 0) {
                if let locationTitle = navigationManager.state.currentLocation {
                    CustomNavigationBar(
                        style: .locationTitle,
                        title: locationTitle,
                        searchText: $searchText,
                        onBackTapped: {
                            navigationManager.dispatch(.changeCurrentLocation(nil))
                        }
                    )
                    .frame(height: 56.adjusted)
                } else {
                    CustomNavigationBar(
                        style: .searchContent,
                        searchText: $searchText,
                        spoonCount: spoonCount,
                        tappedAction: {
                            navigationManager.dispatch(.push(.searchView))
                        }
                    )
                    .frame(height: 56.adjusted)
                }
                Spacer()
            }
            
            Group {
                if !viewModel.focusedPlaces.isEmpty {
                    PlaceCard(
                        places: viewModel.focusedPlaces,
                        currentPage: $currentPage
                    )
                    .padding(.bottom, 12)
                    .transition(.move(edge: .bottom))
                } else {
                    if navigationManager.state.currentLocation != nil {
                        BottomSheetListView(viewModel: viewModel)
                    } else if !viewModel.pickList.isEmpty {
                        BottomSheetListView(viewModel: viewModel)
                    } else {
                        FixedBottomSheetView()
                    }
                }
            }
        } 
        .navigationBarHidden(true)
        .task {
            isBottomSheetPresented = true
            Task {
                do {
                    spoonCount = try await restaurantService.fetchSpoonCount(userId: Config.userId)
                } catch {
                    print("Failed to fetch spoon count:", error)
                }
                viewModel.fetchPickList()
            }
            viewModel.fetchPickList()
        }
    }
}

#Preview {
    Home().environmentObject(NavigationManager())
}

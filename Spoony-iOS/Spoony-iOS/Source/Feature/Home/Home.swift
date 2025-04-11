//
//  Home.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/2/25.
//

import SwiftUI

import ComposableArchitecture
import FlexSheet

struct Home: View {
//    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject private var viewModel = HomeViewModel(service: DefaultHomeService())
    @State private var isBottomSheetPresented = true
    @State private var searchText = ""
    @State private var selectedPlace: CardPlace?
    @State private var currentPage = 0
    @State private var spoonCount: Int = 0
    private let restaurantService: HomeServiceType
    private let store: StoreOf<MapFeature>
    
    init(restaurantService: HomeServiceType = DefaultHomeService(), store: StoreOf<MapFeature>) {
        self.restaurantService = restaurantService
        self.store = store
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
                    } else {
                        selectedPlace = nil
                    }
                }
            
            VStack(spacing: 0) {
                CustomNavigationBar(
                    style: .searchContent,
                    searchText: $searchText,
                    spoonCount: spoonCount,
                    tappedAction: {
                        store.send(.routToSearchScreen)
//                        navigationManager.push(.searchView)
                    }
                )
                .frame(height: 56.adjusted)
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
                    if !viewModel.pickList.isEmpty {
                        FlexibleListBottomSheet(viewModel: viewModel)
                    } else {
                        EmptyStateBottomSheet()
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            isBottomSheetPresented = true
            do {
                spoonCount = try await restaurantService.fetchSpoonCount()
                viewModel.fetchPickList()
            } catch {
                print("Failed to fetch spoon count:", error)
            }
        }
    }
}

#Preview {
    Home(store: Store(initialState: .initialState) {
        MapFeature()
    }).environmentObject(NavigationManager())
}

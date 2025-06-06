//
//  SearchLocationView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 5/3/25.
//

import SwiftUI
import ComposableArchitecture
import CoreLocation

struct SearchLocationView: View {
    @Bindable private var store: StoreOf<SearchLocationFeature>
    @State private var viewModel: HomeViewModel
    
    init(store: StoreOf<SearchLocationFeature>) {
        self.store = store
        self._viewModel = State(initialValue: HomeViewModel(service: DefaultHomeService()))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            if store.isLoading {
                ProgressView()
            } else {
                NMapView(
                    store: store.scope(state: \.mapState, action: \.map),
                    selectedPlace: Binding(
                        get: { store.mapState.selectedPlace },
                        set: { store.send(.map(.selectPlace($0))) }
                    ),
                    isLocationFocused: store.mapState.isLocationFocused,
                    userLocation: store.mapState.userLocation,
                    focusedPlaces: store.focusedPlaces,
                    pickList: store.pickList,
                    selectedLocation: store.mapState.selectedLocation
                )
                .edgesIgnoringSafeArea(.all)
                .onChange(of: store.focusedPlaces) { _, newPlaces in
                    store.send(.updatePlaces(focusedPlaces: newPlaces))
                }
                
                VStack(spacing: 0) {
                    CustomNavigationBar(
                        style: .locationTitle,
                        title: store.locationTitle,
                        onBackTapped: {
                            store.send(.routeToHomeScreen)
                        }
                    )
                    .frame(height: 56.adjusted)
                    Spacer()
                }
                
                Group {
                    if !store.focusedPlaces.isEmpty {
                        PlaceCard(
                            store: store.scope(state: \.mapState, action: \.map),
                            places: store.focusedPlaces,
                            currentPage: Binding(
                                get: { store.mapState.currentPage },
                                set: { store.send(.map(.setCurrentPage($0))) }
                            )
                        )
                        .padding(.bottom, 12)
                        .transition(.move(edge: .bottom))
                    } else {
                        if !store.pickList.isEmpty {
                            FlexibleListBottomSheet(
                                viewModel: viewModel,
                                store: store.scope(state: \.mapState, action: \.map)
                            )
                        } else {
                            FixedBottomSheetView(
                                store: store.scope(state: \.mapState, action: \.map)
                            )
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            store.send(.onAppear)
            store.send(.map(.fetchUserInfo))
            
            if let lat = store.searchedLatitude, let lng = store.searchedLongitude {
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                store.send(.map(.focusToLocation(coordinate)))
            }
            
            Task {
                await viewModel.fetchLocationList(locationId: store.locationId)
            }
        }
        .onChange(of: store.pickList) { _, newPickList in
            viewModel.pickList = newPickList
        }
    }
}

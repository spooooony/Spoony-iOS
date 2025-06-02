//
//  Home.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/2/25.
//

import SwiftUI
import ComposableArchitecture
import CoreLocation

struct Home: View {
    @Bindable private var store: StoreOf<MapFeature>
    @State private var locationManager = CLLocationManager()
    
    init(store: StoreOf<MapFeature>) {
        self.store = store
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            NMapView(
                store: store,
                selectedPlace: Binding(
                    get: { store.selectedPlace },
                    set: { store.send(.selectPlace($0)) }
                ),
                isLocationFocused: store.isLocationFocused,
                userLocation: store.userLocation,
                focusedPlaces: store.focusedPlaces,
                pickList: store.filteredPickList,
                selectedLocation: store.selectedLocation
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                CustomNavigationBar(
                    style: .searchContent,
                    searchText: $store.searchText.sending(\.setSearchText),
                    spoonCount: store.spoonCount,
                    spoonTapped: {
                        store.send(.setShowDailySpoonPopup(true))
                    },
                    tappedAction: {
                        store.send(.routToSearchScreen)
                    }
                )
                .frame(height: 56.adjusted)
                
                HStack(spacing: 8) {
                    if store.categories.isEmpty {
                        ForEach(0..<4, id: \.self) { _ in
                            CategoryChipsView(category: CategoryChip.placeholder)
                                .redacted(reason: .placeholder)
                        }
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                CategoryChipsView(
                                    category: CategoryChip(
                                        image: "",
                                        selectedImage: "",
                                        title: "전체",
                                        id: 0
                                    ),
                                    isSelected: store.selectedCategories.isEmpty || store.selectedCategories.contains { $0.id == 0 }
                                )
                                .onTapGesture {
                                    store.send(.selectCategory(CategoryChip(
                                        image: "",
                                        selectedImage: "",
                                        title: "전체",
                                        id: 0
                                    )))
                                }
                                
                                ForEach(store.categories, id: \.id) { category in
                                    CategoryChipsView(
                                        category: category,
                                        isSelected: store.selectedCategories.contains { $0.id == category.id }
                                    )
                                    .onTapGesture {
                                        store.send(.selectCategory(category))
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.vertical, 8)
                
                Spacer()
            }
            
            ZStack(alignment: .bottomTrailing) {
                if store.currentBottomSheetStyle != .full {
                    Button(action: {
                        store.send(.moveToUserLocation)
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 44.adjusted, height: 44.adjusted)
                                .shadow(color: Color.gray300, radius: 16, x: 1, y: 1)
                            
                            Image(store.isLocationFocused ? "ic_gps_main" : "ic_gps_gray500")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24.adjusted, height: 24.adjusted)
                        }
                    }
                    .padding(.bottom, store.bottomSheetHeight - 68)
                    .padding(.trailing, 20)
                }
                
                Group {
                    if !store.focusedPlaces.isEmpty {
                        PlaceCard(
                            store: store,
                            places: store.focusedPlaces,
                            currentPage: Binding(
                                get: { store.currentPage },
                                set: { store.send(.setCurrentPage($0)) }
                            )
                        )
                        .padding(.bottom, 12)
                        .transition(.move(edge: .bottom))
                    } else {
                        if !store.filteredPickList.isEmpty {
                            BottomSheetListView(
                                store: store,
                                currentStyle: Binding(
                                    get: { store.currentBottomSheetStyle },
                                    set: { store.send(.setBottomSheetStyle($0)) }
                                ),
                                bottomSheetHeight: Binding(
                                    get: { store.bottomSheetHeight },
                                    set: { _ in }
                                )
                            )
                        } else {
                            FixedBottomSheetView(store: store)
                        }
                    }
                }
            }
            
            #if DEBUG
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        store.send(.setShowDailySpoonPopup(true))
                    }) {
                        Text("스푼 뽑기 테스트")
                            .font(.caption1b)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.main400)
                            .cornerRadius(20)
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, store.bottomSheetHeight + 16)
                }
            }
            #endif
        }
        .navigationBarHidden(true)
        .toolbar(store.showDailySpoonPopup ? .hidden : .visible, for: .tabBar)
        .task {
            checkPermissions()
            store.send(.fetchUserInfo)   
            store.send(.fetchSpoonCount)
            store.send(.fetchPickList)
            store.send(.fetchCategories)
            store.send(.checkDailyVisit)
        }
        .overlay {
            if store.showDailySpoonPopup {
                SpoonDrawPopupView(
                    isPresented: Binding(
                        get: { store.showDailySpoonPopup },
                        set: { store.send(.setShowDailySpoonPopup($0)) }
                    ),
                    onDrawSpoon: {
                        store.send(.drawDailySpoon)
                    },
                    isDrawing: store.isDrawingSpoon,
                    drawnSpoon: store.drawnSpoon,
                    errorMessage: store.spoonDrawError
                )
            }
        }
    }
    
    private func checkPermissions() {
        locationManager.delegate = LocationManagerDelegate(onLocationUpdate: { location in
            store.send(.updateUserLocation(location))
        })
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}

class LocationManagerDelegate: NSObject, CLLocationManagerDelegate, ObservableObject {
    let onLocationUpdate: (CLLocation) -> Void?
    
    init(onLocationUpdate: @escaping (CLLocation) -> Void) {
        self.onLocationUpdate = onLocationUpdate
        super.init()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            onLocationUpdate(location)
        }
    }
}

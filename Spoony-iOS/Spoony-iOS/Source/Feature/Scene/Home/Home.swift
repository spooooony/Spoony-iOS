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
    @State private var locationDelegate: LocationManagerDelegate?
    
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
                        handleGPSButtonTap()
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
                    .padding(.bottom, store.filteredPickList.isEmpty ?
                        (UIScreen.main.bounds.height * 0.5 - 68) :
                        (store.bottomSheetHeight - 68)
                    )
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
            setupLocationManager()
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
    
    private func setupLocationManager() {
        locationDelegate = LocationManagerDelegate(onLocationUpdate: { location in
            store.send(.updateUserLocation(location))
        })
        locationManager.delegate = locationDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func handleGPSButtonTap() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            if let currentLocation = locationManager.location {
                store.send(.updateUserLocation(currentLocation))
                store.send(.moveToUserLocation)
            } else {
                locationManager.requestLocation()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if let location = locationManager.location {
                        store.send(.updateUserLocation(location))
                        store.send(.moveToUserLocation)
                    }
                }
            }
        case .denied, .restricted:
            showLocationPermissionAlert()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
    private func showLocationPermissionAlert() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let alert = UIAlertController(
            title: "위치 권한 필요",
            message: "현재 위치를 확인하려면 위치 권한이 필요합니다. 설정에서 위치 권한을 허용해주세요.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        })
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        window.rootViewController?.present(alert, animated: true)
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        if let clError = error as? CLError {
            switch clError.code {
            case .locationUnknown:
                print("📍 위치를 확인할 수 없습니다")
            case .denied:
                print("📍 위치 권한이 거부되었습니다")
            case .network:
                print("📍 네트워크 오류로 위치를 확인할 수 없습니다")
            default:
                print("📍 기타 위치 오류: \(clError.localizedDescription)")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            manager.stopUpdatingLocation()
        case .notDetermined:
            print("📍 위치 권한 미결정")
        default:
            break
        }
    }
}

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
    
    @State private var locationManager = CLLocationManager()
    @State private var locationDelegate: LocationManagerDelegate?
    
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
                    userLocation: store.mapState.isLocationFocused ? store.mapState.userLocation : nil,
                    focusedPlaces: store.mapState.focusedPlaces,
                    pickList: store.pickList,
                    selectedLocation: store.selectedLocation
                )
                .edgesIgnoringSafeArea(.all)
                
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
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        if store.mapState.currentBottomSheetStyle != .full && store.mapState.focusedPlaces.isEmpty {
                            Button(action: handleGPSButtonTap) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 44.adjusted, height: 44.adjusted)
                                        .shadow(color: Color.gray300, radius: 16, x: 1, y: 1)
                                    
                                    Image(store.mapState.isLocationFocused ? "ic_gps_main" : "ic_gps_gray500")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24.adjusted, height: 24.adjusted)
                                }
                            }
                        }
                    }
                    .padding(.bottom, store.pickList.isEmpty ?
                        (UIScreen.main.bounds.height * 0.5 - 68) :
                        (store.mapState.bottomSheetHeight - 68)
                    )
                    .padding(.trailing, 20)
                }
                
                Group {
                    if !store.mapState.focusedPlaces.isEmpty {
                        SearchLocationPlaceCard(
                            places: store.mapState.focusedPlaces,
                            currentPage: Binding(
                                get: { store.mapState.currentPage },
                                set: { store.send(.map(.setCurrentPage($0))) }
                            ),
                            onCardTapped: { place in
                                // 플레이스 카드를 탭했을 때 디테일 뷰로 이동
                                store.send(.routeToPostDetail(postId: place.postId))
                            }
                        )
                        .padding(.bottom, 12)
                        .transition(.move(edge: .bottom))
                    } else {
                        if !store.pickList.isEmpty {
                            SearchLocationBottomSheetListView(
                                mapStore: store.scope(state: \.mapState, action: \.map),
                                pickList: store.pickList,
                                locationTitle: store.locationTitle
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
            if let searchedLatitude = store.searchedLatitude,
               let searchedLongitude = store.searchedLongitude {
                store.send(.setSelectedLocation(latitude: searchedLatitude, longitude: searchedLongitude))
            }
            
            if store.searchedLatitude != nil && store.searchedLongitude != nil {
                if store.mapState.isLocationFocused {
                    store.send(.map(.toggleGPSTracking))
                }
            }
            
            setupLocationManager()
            store.send(.onAppear)
            store.send(.map(.fetchUserInfo))
            
            Task {
                await viewModel.fetchLocationList(locationId: store.locationId)
            }
        }
        .onChange(of: store.pickList) { _, newPickList in
            viewModel.pickList = newPickList
        }
    }
    
    private func setupLocationManager() {
        locationDelegate = LocationManagerDelegate(onLocationUpdate: { location in
            store.send(.map(.updateUserLocation(location)))
        })
        locationManager.delegate = locationDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func handleGPSButtonTap() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            if store.mapState.isLocationFocused {
                store.send(.map(.toggleGPSTracking))
            } else {
                locationManager.startUpdatingLocation()
                if let currentLocation = locationManager.location {
                    store.send(.map(.updateUserLocation(currentLocation)))
                    store.send(.map(.moveToUserLocation))
                } else {
                    locationManager.requestLocation()
                }
            }
        case .denied, .restricted:
            showLocationPermissionAlert()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if self.locationManager.authorizationStatus == .authorizedWhenInUse ||
                   self.locationManager.authorizationStatus == .authorizedAlways {
                    self.locationManager.startUpdatingLocation()
                    self.locationManager.requestLocation()
                }
            }
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

struct SearchLocationBottomSheetListView: View {
    private let store: StoreOf<MapFeature>
    let pickList: [PickListCardResponse]
    let locationTitle: String
    
    @State private var currentStyle: BottomSheetStyle = .half
    @State private var bottomSheetHeight: CGFloat = BottomSheetStyle.half.height
    @State private var offset: CGFloat = 0
    @GestureState private var isDragging: Bool = false
    @State private var isScrollEnabled: Bool = false
    
    init(mapStore: StoreOf<MapFeature>, pickList: [PickListCardResponse], locationTitle: String) {
        self.store = mapStore
        self.pickList = pickList
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
                        Text("\(pickList.count)")
                            .customFont(.body2b)
                            .foregroundColor(.gray500)
                    }
                    .padding(.bottom, 8)
                }
                .frame(height: 60.adjustedH)
                .background(Color.white)
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(pickList, id: \.placeId) { pickCard in
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
                store.send(.setBottomSheetStyle(newStyle))
            }
            .onAppear {
                bottomSheetHeight = currentStyle.height
                store.send(.setBottomSheetStyle(currentStyle))
            }
        }
        .ignoresSafeArea()
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
}

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
    
    @State private var currentBottomSheetHeight: CGFloat = BottomSheetStyle.half.height
    @State private var currentBottomSheetStyle: BottomSheetStyle = .half
    
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
                    selectedLocation: store.selectedLocation
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
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        if currentBottomSheetStyle != .full && store.focusedPlaces.isEmpty {
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
                        (currentBottomSheetHeight - 68)
                    )
                    .padding(.trailing, 20)
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
                            FlexibleListBottomSheetWrapper(
                                viewModel: viewModel,
                                store: store.scope(state: \.mapState, action: \.map),
                                onHeightChanged: { height in
                                    currentBottomSheetHeight = height
                                },
                                onStyleChanged: { style in
                                    currentBottomSheetStyle = style
                                }
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
            setupLocationManager()
            store.send(.onAppear)
            store.send(.map(.fetchUserInfo))
            Task {
                await viewModel.fetchLocationList(locationId: store.locationId)
            }
            
            currentBottomSheetHeight = store.pickList.isEmpty ?
                UIScreen.main.bounds.height * 0.5 :
                BottomSheetStyle.half.height
            currentBottomSheetStyle = .half
        }
        .onChange(of: store.pickList) { _, newPickList in
            viewModel.pickList = newPickList
            
            currentBottomSheetHeight = newPickList.isEmpty ?
                UIScreen.main.bounds.height * 0.5 :
                BottomSheetStyle.half.height
        }
    }
    
    private func setupLocationManager() {
        locationDelegate = LocationManagerDelegate(onLocationUpdate: { location in
            store.send(.map(.updateUserLocation(location)))
        })
        locationManager.delegate = locationDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func handleGPSButtonTap() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            if store.mapState.isLocationFocused {
                store.send(.map(.toggleGPSTracking))
            } else {
                if let currentLocation = locationManager.location {
                    store.send(.map(.updateUserLocation(currentLocation)))
                    store.send(.map(.moveToUserLocation))
                } else {
                    locationManager.requestLocation()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if let location = self.locationManager.location {
                            store.send(.map(.updateUserLocation(location)))
                            store.send(.map(.moveToUserLocation))
                        }
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

struct FlexibleListBottomSheetWrapper: View {
    @ObservedObject var viewModel: HomeViewModel
    private let store: StoreOf<MapFeature>
    let onHeightChanged: (CGFloat) -> Void
    let onStyleChanged: (BottomSheetStyle) -> Void
    
    @State private var currentStyle: BottomSheetStyle = .half
    @State private var offset: CGFloat = 0
    @GestureState private var isDragging: Bool = false
    @State private var isScrollEnabled: Bool = false
    
    init(viewModel: HomeViewModel,
         store: StoreOf<MapFeature>,
         onHeightChanged: @escaping (CGFloat) -> Void,
         onStyleChanged: @escaping (BottomSheetStyle) -> Void) {
        self.viewModel = viewModel
        self.store = store
        self.onHeightChanged = onHeightChanged
        self.onStyleChanged = onStyleChanged
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
                        Text("\(store.userName)님의 찐맛집")
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
                                        onHeightChanged(currentStyle.height)
                                        onStyleChanged(currentStyle)
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
            .frame(maxHeight: .infinity)
            .background(Color.white)
            .cornerRadius(10, corners: [.topLeft, .topRight])
            .offset(y: geometry.size.height - currentStyle.height + offset)
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
                            onHeightChanged(currentStyle.height - translation)
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
                            let screenHeight = geometry.size.height
                            let currentOffset = screenHeight - currentStyle.height + translation
                            currentStyle = getClosestSnapPoint(to: currentOffset, in: geometry)
                            isScrollEnabled = (currentStyle == .full)
                        }
                        
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            offset = 0
                            onHeightChanged(currentStyle.height)
                            onStyleChanged(currentStyle)
                        }
                    }
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentStyle)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: offset)
            .onAppear {
                onHeightChanged(currentStyle.height)
                onStyleChanged(currentStyle)
            }
            .onChange(of: currentStyle) { _, newStyle in
                isScrollEnabled = (newStyle == .full)
                onHeightChanged(newStyle.height)
                onStyleChanged(newStyle)
            }
        }
        .ignoresSafeArea()
    }
    
    private func getClosestSnapPoint(to offset: CGFloat, in geometry: GeometryProxy) -> BottomSheetStyle {
        let screenHeight = geometry.size.height
        let currentHeight = screenHeight - offset
        
        let distances = [
            (abs(currentHeight - BottomSheetStyle.minimal.height), BottomSheetStyle.minimal),
            (abs(currentHeight - BottomSheetStyle.half.height), BottomSheetStyle.half),
            (abs(currentHeight - BottomSheetStyle.full.height), BottomSheetStyle.full)
        ]
        
        return distances.min(by: { $0.0 < $1.0 })?.1 ?? .half
    }
}

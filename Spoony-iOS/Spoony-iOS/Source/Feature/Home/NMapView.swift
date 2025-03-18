//
//  NMapView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/14/25.
//

import SwiftUI
import NMapsMap

struct NMapView: UIViewRepresentable {
    private let defaultZoomLevel: Double = 11.5
    private let defaultMarker = NMFOverlayImage(name: "ic_unselected_marker")
    private let selectedMarker = NMFOverlayImage(name: "ic_selected_marker")
    private let defaultLatitude: Double = 37.5666103
    private let defaultLongitude: Double = 126.9783882
    private let locationManager = CLLocationManager()
    @ObservedObject var viewModel: HomeViewModel
    @Binding var selectedPlace: CardPlace?
    
    let onMoveCamera: ((Double, Double) -> Void)?
    
    init(viewModel: HomeViewModel,
         selectedPlace: Binding<CardPlace?>,
         onMoveCamera: ((Double, Double) -> Void)? = nil) {
        locationManager.requestWhenInUseAuthorization()
        self.viewModel = viewModel
        self._selectedPlace = selectedPlace
        self.onMoveCamera = onMoveCamera
    }
    
    func makeUIView(context: Context) -> NMFMapView {
        let mapView = configureMapView(context: context)
        checkLocationPermission(mapView)
        return mapView
    }
    
    private func checkLocationPermission(_ mapView: NMFMapView) {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            if let location = locationManager.location {
                moveCamera(mapView, to: NMGLatLng(lat: location.coordinate.latitude,
                                                  lng: location.coordinate.longitude))
            }
        case .denied, .restricted:
            moveCamera(mapView, to: NMGLatLng(lat: defaultLatitude, lng: defaultLongitude))
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            moveCamera(mapView, to: NMGLatLng(lat: defaultLatitude, lng: defaultLongitude))
        default:
            moveCamera(mapView, to: NMGLatLng(lat: defaultLatitude, lng: defaultLongitude))
        }
    }
    
    private func moveCamera(_ mapView: NMFMapView, to coord: NMGLatLng) {
        let cameraUpdate = NMFCameraUpdate(scrollTo: coord)
        mapView.moveCamera(cameraUpdate)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            selectedPlace: $selectedPlace,
            defaultMarkerImage: defaultMarker,
            selectedMarkerImage: selectedMarker,
            viewModel: viewModel
        )
    }
    
    func updateUIView(_ mapView: NMFMapView, context: Context) {
        mapView.touchDelegate = context.coordinator
        updateMarkers(mapView: mapView, context: context)
        
        // 선택된 장소가 있으면 해당 위치로 카메라 이동
        if let location = viewModel.selectedLocation {
            let coord = NMGLatLng(lat: location.latitude, lng: location.longitude)
            let cameraUpdate = NMFCameraUpdate(scrollTo: coord)
            cameraUpdate.animation = .easeIn
            cameraUpdate.animationDuration = 0.2
            mapView.moveCamera(cameraUpdate)
        }
        
        // 처음 지도가 로드될 때만 모든 마커가 보이도록 카메라 이동
        if context.coordinator.isInitialLoad && !viewModel.pickList.isEmpty {
            let bounds = NMGLatLngBounds(latLngs: viewModel.pickList.map {
                NMGLatLng(lat: $0.latitude, lng: $0.longitude)
            })
            let cameraUpdate = NMFCameraUpdate(fit: bounds, padding: 50)
            mapView.moveCamera(cameraUpdate)
            context.coordinator.isInitialLoad = false
        }
    }
    
    private func updateMarkers(mapView: NMFMapView, context: Context) {
        context.coordinator.clearAllMarkers()
        
        let newMarkers = viewModel.pickList.map { pickCard in
            let marker = createMarker(for: pickCard, coordinator: context.coordinator)
            marker.mapView = mapView
            return marker
        }
        
        context.coordinator.markers = newMarkers
        
        // 선택된 장소가 있으면 해당 마커 선택 상태로 변경
        if let selected = selectedPlace {
            if let markerToUpdate = context.coordinator.markers.first(where: { marker in
                guard let userData = marker.userInfo["placeId"] as? Int else { return false }
                return userData == selected.placeId
            }) {
                markerToUpdate.iconImage = selectedMarker
                markerToUpdate.zIndex = 2
                markerToUpdate.captionMinZoom = 0
                
                context.coordinator.lastSelectedMarker = markerToUpdate
            }
        }
    }
    
    private func configureMapView(context: Context) -> NMFMapView {
        let mapView = NMFMapView()
        mapView.positionMode = .disabled
        mapView.zoomLevel = defaultZoomLevel
        mapView.touchDelegate = context.coordinator
        mapView.logoAlign = .rightTop
        mapView.logoInteractionEnabled = true
        mapView.logoMargin = UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 12)
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleMapTap(_:)))
        tapGesture.delegate = context.coordinator
        mapView.addGestureRecognizer(tapGesture)
        
        return mapView
    }
    
    private func createMarker(for pickCard: PickListCardResponse, coordinator: Coordinator) -> NMFMarker {
        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: pickCard.latitude, lng: pickCard.longitude)
        marker.width = CGFloat(NMF_MARKER_SIZE_AUTO)
        marker.height = CGFloat(NMF_MARKER_SIZE_AUTO)
        marker.iconImage = defaultMarker
        marker.zIndex = 1
        
        marker.userInfo = ["placeId": pickCard.placeId, "placeName": pickCard.placeName]
        
        marker.captionText = pickCard.placeName
        marker.captionTextSize = 14
        marker.captionColor = .black
        marker.captionMinZoom = 10
        marker.captionMaxZoom = 20
        marker.captionOffset = -12
        marker.captionAligns = [.bottom]
        
        marker.touchHandler = { [weak coordinator] _ -> Bool in
            guard let coordinator = coordinator else { return false }
            coordinator.isMarkerTouched = true
            
            let isAlreadySelected = coordinator.lastSelectedMarker === marker
            coordinator.resetAllMarkers()
            
            if isAlreadySelected {
                coordinator.lastSelectedMarker = nil
                
                DispatchQueue.main.async {
                    coordinator.selectedPlace = nil
                    coordinator.viewModel.clearFocusedPlaces()
                }
            } else {
                marker.iconImage = coordinator.selectedMarkerImage
                marker.zIndex = 2
                marker.captionMinZoom = 0
                
                coordinator.lastSelectedMarker = marker

                coordinator.viewModel.fetchFocusedPlace(placeId: pickCard.placeId)
            }
            
            return true
        }
        
        return marker
    }
}

final class Coordinator: NSObject, NMFMapViewTouchDelegate, UIGestureRecognizerDelegate {
    @Binding var selectedPlace: CardPlace?
    var markers: [NMFMarker] = []
    var isInitialLoad: Bool = true
    var isMarkerTouched: Bool = false // 마커 터치 여부 플래그
    var lastSelectedMarker: NMFMarker? // 마지막으로 선택된 마커
    
    let defaultMarkerImage: NMFOverlayImage
    let selectedMarkerImage: NMFOverlayImage
    let viewModel: HomeViewModel
    
    init(selectedPlace: Binding<CardPlace?>,
         defaultMarkerImage: NMFOverlayImage,
         selectedMarkerImage: NMFOverlayImage,
         viewModel: HomeViewModel) {
        self._selectedPlace = selectedPlace
        self.defaultMarkerImage = defaultMarkerImage
        self.selectedMarkerImage = selectedMarkerImage
        self.viewModel = viewModel
        super.init()
    }
    
    @objc func handleMapTap(_ gesture: UITapGestureRecognizer) {
        // 마커 터치 이벤트가 발생한 경우 플래그 체크 후 리셋
        if isMarkerTouched {
            isMarkerTouched = false
            return
        }
        
        print("지도 터치 감지됨 (UITapGestureRecognizer)")
        
        // 선택된 장소 초기화
        DispatchQueue.main.async { [weak self] in
            self?.selectedPlace = nil
            self?.viewModel.clearFocusedPlaces()
            self?.resetAllMarkers()
            self?.lastSelectedMarker = nil
        }
    }
    
    // UIGestureRecognizerDelegate -> 다른 터치 이벤트와 동시에 처리 허용
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // NMapsMap 터치 이벤트 (NMFMapViewTouchDelegate)
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng) -> Bool {
        // NMapsMap의 didTapMap은 마커를 터치하지 않은 경우에만 호출됨 -> handleMapTap에서 처리하도록 false 반환

        return false
    }
    
    func clearAllMarkers() {
        markers.forEach { marker in
            marker.mapView = nil
        }
        markers.removeAll()
    }
    
    func resetAllMarkers() {
        markers.forEach { marker in
            marker.iconImage = defaultMarkerImage
            marker.zIndex = 1
            marker.captionMinZoom = 10
        }
    }
}

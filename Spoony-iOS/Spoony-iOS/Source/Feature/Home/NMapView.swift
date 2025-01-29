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
    
    private var mapView: NMFMapView
    let onMoveCamera: ((Double, Double) -> Void)?
    
    init(viewModel: HomeViewModel,
         selectedPlace: Binding<CardPlace?>,
         onMoveCamera: ((Double, Double) -> Void)? = nil) {
        locationManager.requestWhenInUseAuthorization()
        self.viewModel = viewModel
        self._selectedPlace = selectedPlace
        self.onMoveCamera = onMoveCamera
        self.mapView = NMFMapView()
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
            viewModel: viewModel
        )
    }
    
    func updateUIView(_ mapView: NMFMapView, context: Context) {
        context.coordinator.markers.forEach { marker in
            marker.mapView = nil
        }
        context.coordinator.markers.removeAll()
        
        let newMarkers = viewModel.pickList.map { pickCard in
            let marker = createMarker(for: pickCard)
            marker.mapView = mapView
            return marker
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
        
        // 마커가 선택됐을 때만 해당 위치로 카메라 이동
        if let location = viewModel.selectedLocation {
            let coord = NMGLatLng(lat: location.latitude, lng: location.longitude)
            let cameraUpdate = NMFCameraUpdate(scrollTo: coord)
            cameraUpdate.animation = .easeIn
            cameraUpdate.animationDuration = 0.2
            mapView.moveCamera(cameraUpdate)
        }
        
        context.coordinator.markers = newMarkers
    }
    
    private func configureMapView(context: Context) -> NMFMapView {
        let mapView = NMFMapView()
        mapView.positionMode = .disabled
        mapView.zoomLevel = defaultZoomLevel
        mapView.touchDelegate = context.coordinator
        mapView.logoAlign = .rightTop
        mapView.logoInteractionEnabled = true
        mapView.logoMargin = UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 12)
        return mapView
    }
    
    private func configureMarkerCaption(_ marker: NMFMarker, with placeName: String, isSelected: Bool) {
        marker.captionText = placeName
        marker.captionColor = .black
        marker.captionTextSize = 14
        
        marker.captionMinZoom = isSelected ? 0 : 10
        marker.captionMaxZoom = 20
        
        marker.anchor = CGPoint(x: 0.5, y: 1.0)
        marker.captionOffset = -12
        marker.captionAligns = [.bottom]
    }
    
    private func resetMarker(_ marker: NMFMarker) {
        marker.mapView = nil
        marker.iconImage = defaultMarker
        configureMarkerCaption(marker, with: marker.captionText, isSelected: false)
        marker.anchor = CGPoint(x: 0.5, y: 1.0)
    }
    
    private func createMarker(for pickCard: PickListCardResponse) -> NMFMarker {
        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: pickCard.latitude, lng: pickCard.longitude)
        marker.width = CGFloat(NMF_MARKER_SIZE_AUTO)
        marker.height = CGFloat(NMF_MARKER_SIZE_AUTO)
        
        let isSelected = selectedPlace?.placeId == pickCard.placeId
        
        if isSelected {
            marker.iconImage = selectedMarker
        } else {
            marker.iconImage = defaultMarker
        }
        
        // 모든 마커에 캡션 설정
        configureMarkerCaption(marker, with: pickCard.placeName, isSelected: isSelected)
        
        marker.touchHandler = { [weak viewModel, weak marker] (_) -> Bool in
            guard let marker = marker else { return false }
            
            let isCurrentlySelected = (marker.iconImage == selectedMarker)
            
            if !isCurrentlySelected {
                marker.iconImage = selectedMarker
                configureMarkerCaption(marker, with: pickCard.placeName, isSelected: true)
                viewModel?.fetchFocusedPlace(placeId: pickCard.placeId)
            } else {
                resetMarker(marker)
                marker.mapView = mapView
                selectedPlace = nil
            }
            
            return true
        }
        
        return marker
    }
}

final class Coordinator: NSObject, NMFMapViewTouchDelegate {
    @Binding var selectedPlace: CardPlace?
    var markers: [NMFMarker] = []
    var isInitialLoad = true
    private let defaultMarkerImage: NMFOverlayImage
    private let viewModel: HomeViewModel
    
    init(selectedPlace: Binding<CardPlace?>,
         defaultMarkerImage: NMFOverlayImage,
         viewModel: HomeViewModel) {
        self._selectedPlace = selectedPlace
        self.defaultMarkerImage = defaultMarkerImage
        self.viewModel = viewModel
    }
    
    @MainActor func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng) -> Bool {
        selectedPlace = nil
        
        markers.forEach { marker in
            marker.iconImage = defaultMarkerImage
            marker.captionMinZoom = 10
        }
        
        if !viewModel.focusedPlaces.isEmpty {
            DispatchQueue.main.async {
                self.viewModel.clearFocusedPlaces()
            }
        }
        
        return true
    }
}

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
    private let userLocationZoomLevel: Double = 15.0
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
        
        locationManager.delegate = context.coordinator
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        return mapView
    }
    
    private func checkLocationPermission(_ mapView: NMFMapView) {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            if let location = locationManager.location {
                viewModel.updateUserLocation(location)
                if viewModel.selectedLocation == nil {
                    moveCamera(mapView, to: NMGLatLng(lat: location.coordinate.latitude,
                                                    lng: location.coordinate.longitude))
                }
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
        context.coordinator.updateMarkers(mapView: mapView, pickList: viewModel.pickList, selectedPlaceId: selectedPlace?.placeId)
        
        if viewModel.isLocationFocused, let userLocation = viewModel.userLocation {
            let coord = NMGLatLng(lat: userLocation.coordinate.latitude, lng: userLocation.coordinate.longitude)
            let cameraUpdate = NMFCameraUpdate(scrollTo: coord, zoomTo: userLocationZoomLevel)
            cameraUpdate.animation = .easeIn
            cameraUpdate.animationDuration = 0.5
            mapView.moveCamera(cameraUpdate)
            
            context.coordinator.updateUserLocationMarker(mapView: mapView, location: userLocation)
        }

        else if let location = viewModel.selectedLocation, !viewModel.focusedPlaces.isEmpty {
            let coord = NMGLatLng(lat: location.latitude, lng: location.longitude)
            let cameraUpdate = NMFCameraUpdate(scrollTo: coord)
            cameraUpdate.animation = .easeIn
            cameraUpdate.animationDuration = 0.2
            mapView.moveCamera(cameraUpdate)
        }
        
        if context.coordinator.isInitialLoad && !viewModel.pickList.isEmpty {
            let bounds = NMGLatLngBounds(latLngs: viewModel.pickList.map {
                NMGLatLng(lat: $0.latitude, lng: $0.longitude)
            })
            let cameraUpdate = NMFCameraUpdate(fit: bounds, padding: 50)
            mapView.moveCamera(cameraUpdate)
            context.coordinator.isInitialLoad = false
        }
    }
    
    private func configureMapView(context: Context) -> NMFMapView {
        let mapView = NMFMapView()
        mapView.positionMode = .normal
        mapView.zoomLevel = defaultZoomLevel
        mapView.touchDelegate = context.coordinator
        mapView.logoAlign = .rightTop
        mapView.logoInteractionEnabled = true
        let chipAreaHeight = 100.adjustedH
        mapView.logoMargin = UIEdgeInsets(top: chipAreaHeight, left: 0, bottom: 0, right: 20)
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleMapTap(_:)))
        tapGesture.delegate = context.coordinator
        mapView.addGestureRecognizer(tapGesture)
        
        return mapView
    }
}

final class Coordinator: NSObject, NMFMapViewTouchDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate {
    @Binding var selectedPlace: CardPlace?
    var markers: [Int: NMFMarker] = [:]
    var isInitialLoad: Bool = true
    var userLocationMarker: NMFMarker?
    
    private var isProcessingMarkerTouch = false
    private var lastMarkerTouchTime: TimeInterval = 0
    
    private let defaultMarkerImage: NMFOverlayImage
    private let selectedMarkerImage: NMFOverlayImage
    private let viewModel: HomeViewModel
    
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
    
    // CLLocationManagerDelegate method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        viewModel.updateUserLocation(location)
        
        // If we're focusing on user location, update the camera
        if viewModel.isLocationFocused {
            // The map view will handle this in updateUIView
        }
    }
    
    // Handle authorization changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
    
    // Update or create user location marker
    func updateUserLocationMarker(mapView: NMFMapView, location: CLLocation) {
        if userLocationMarker == nil {
            userLocationMarker = NMFMarker()
            userLocationMarker?.iconImage = NMFOverlayImage(name: "ic_my_location")
            userLocationMarker?.width = CGFloat(NMF_MARKER_SIZE_AUTO)
            userLocationMarker?.height = CGFloat(NMF_MARKER_SIZE_AUTO)
            userLocationMarker?.mapView = mapView
        }
        
        userLocationMarker?.position = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
    }
    
    @objc func handleMapTap(_ gesture: UITapGestureRecognizer) {
        if selectedPlace == nil { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            for (_, marker) in self.markers {
                if let placeName = marker.userInfo["placeName"] as? String {
                    marker.iconImage = self.defaultMarkerImage
                    self.configureMarkerCaption(marker, with: placeName, isSelected: false)
                }
            }
            
            self.selectedPlace = nil
            self.viewModel.clearFocusedPlaces()
            
            // When tapping on the map, we're no longer focused on user location
            self.viewModel.isLocationFocused = false
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchPoint = touch.location(in: gestureRecognizer.view)
        if let view = gestureRecognizer.view?.hitTest(touchPoint, with: nil) {
            let className = NSStringFromClass(type(of: view))
            if className.contains("Marker") || className.contains("NMF") {
                return false
            }
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func updateMarkers(mapView: NMFMapView, pickList: [PickListCardResponse], selectedPlaceId: Int?) {
        var currentMarkerIds = Set(markers.keys)
        
        for pickCard in pickList {
            let placeId = pickCard.placeId
            let isSelected = placeId == selectedPlaceId
            
            if let existingMarker = markers[placeId] {
                updateMarker(existingMarker, with: pickCard, isSelected: isSelected)
                currentMarkerIds.remove(placeId)
            } else {
                let newMarker = createMarker(for: pickCard, isSelected: isSelected, mapView: mapView)
                newMarker.mapView = mapView
                markers[placeId] = newMarker
            }
        }
        
        for idToRemove in currentMarkerIds {
            if let markerToRemove = markers[idToRemove] {
                markerToRemove.mapView = nil
                markers.removeValue(forKey: idToRemove)
            }
        }
    }
    
    private func configureMarkerCaption(_ marker: NMFMarker, with placeName: String, isSelected: Bool) {
        marker.captionText = placeName
        marker.captionTextSize = 14
        
        marker.captionMinZoom = isSelected ? 0 : 10
        marker.captionMaxZoom = 20
        
        marker.anchor = CGPoint(x: 0.5, y: 1.0)
        marker.captionOffset = 4
        marker.captionAligns = [.bottom]
    }
    
    private func updateMarker(_ marker: NMFMarker, with pickCard: PickListCardResponse, isSelected: Bool) {
        marker.position = NMGLatLng(lat: pickCard.latitude, lng: pickCard.longitude)
        marker.iconImage = isSelected ? selectedMarkerImage : defaultMarkerImage
        configureMarkerCaption(marker, with: pickCard.placeName, isSelected: isSelected)
    }
    
    private func createMarker(for pickCard: PickListCardResponse, isSelected: Bool, mapView: NMFMapView) -> NMFMarker {
        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: pickCard.latitude, lng: pickCard.longitude)
        marker.width = CGFloat(NMF_MARKER_SIZE_AUTO)
        marker.height = CGFloat(NMF_MARKER_SIZE_AUTO)
        marker.iconImage = isSelected ? selectedMarkerImage : defaultMarkerImage
        
        marker.userInfo = ["placeId": pickCard.placeId, "placeName": pickCard.placeName]
        
        configureMarkerCaption(marker, with: pickCard.placeName, isSelected: isSelected)
        
        marker.touchHandler = { [weak self] _ -> Bool in
            guard let self = self else { return false }
            
            if self.isProcessingMarkerTouch { return true }
            
            self.isProcessingMarkerTouch = true
            self.lastMarkerTouchTime = Date().timeIntervalSince1970
            
            guard let placeId = marker.userInfo["placeId"] as? Int,
                  let placeName = marker.userInfo["placeName"] as? String else {
                self.isProcessingMarkerTouch = false
                return false
            }
            
            let isCurrentlySelected = (self.selectedPlace?.placeId == placeId)
            
            DispatchQueue.main.async {
                // When selecting a marker, we're no longer focused on user location
                self.viewModel.isLocationFocused = false
                
                if !isCurrentlySelected {
                    for (_, m) in self.markers {
                        if let pName = m.userInfo["placeName"] as? String, m !== marker {
                            m.iconImage = self.defaultMarkerImage
                            self.configureMarkerCaption(m, with: pName, isSelected: false)
                        }
                    }
                    
                    marker.iconImage = self.selectedMarkerImage
                    self.configureMarkerCaption(marker, with: placeName, isSelected: true)
                    self.viewModel.fetchFocusedPlace(placeId: placeId)
                } else {
                    self.viewModel.clearFocusedPlaces()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.selectedPlace = nil
                        
                        marker.iconImage = self.defaultMarkerImage
                        self.configureMarkerCaption(marker, with: placeName, isSelected: false)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.isProcessingMarkerTouch = false
                        }
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.isProcessingMarkerTouch = false
                }
            }
            
            return true
        }
        
        return marker
    }
    
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng) -> Bool {
        return false
    }
}


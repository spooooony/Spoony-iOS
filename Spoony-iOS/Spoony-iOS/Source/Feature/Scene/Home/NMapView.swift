//
//  NMapView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/14/25.
//

import SwiftUI
import NMapsMap
import ComposableArchitecture
import CoreLocation

struct NMapView: UIViewRepresentable {
    private let defaultZoomLevel: Double = 11.5
    private let userLocationZoomLevel: Double = 15.0
    private let defaultMarker = NMFOverlayImage(name: "ic_unselected_marker")
    private let selectedMarker = NMFOverlayImage(name: "ic_selected_marker")
    private let defaultLatitude: Double = 37.5563
    private let defaultLongitude: Double = 126.9236
    
    let store: StoreOf<MapFeature>
    @Binding var selectedPlace: CardPlace?
    let isLocationFocused: Bool
    let userLocation: CLLocation?
    let focusedPlaces: [CardPlace]
    let pickList: [PickListCardResponse]
    let selectedLocation: (latitude: Double, longitude: Double)?
    
    func makeUIView(context: Context) -> NMFMapView {
        let mapView = configureMapView(context: context)
        checkLocationPermission(mapView)
        return mapView
    }
    
    private func checkLocationPermission(_ mapView: NMFMapView) {
        let locationManager = CLLocationManager()
        
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            if let location = userLocation {
                moveCamera(mapView, to: NMGLatLng(lat: location.coordinate.latitude,
                                                  lng: location.coordinate.longitude))
            } else if let selectedLocation = selectedLocation {
                moveCamera(mapView, to: NMGLatLng(lat: selectedLocation.latitude, lng: selectedLocation.longitude))
            } else {
                moveCamera(mapView, to: NMGLatLng(lat: defaultLatitude, lng: defaultLongitude))
            }
        case .denied, .restricted:
            moveCamera(mapView, to: NMGLatLng(lat: defaultLatitude, lng: defaultLongitude))
        case .notDetermined:
            moveCamera(mapView, to: NMGLatLng(lat: defaultLatitude, lng: defaultLongitude))
        @unknown default:
            moveCamera(mapView, to: NMGLatLng(lat: defaultLatitude, lng: defaultLongitude))
        }
    }
    
    private func moveCamera(_ mapView: NMFMapView, to coord: NMGLatLng) {
        let cameraUpdate = NMFCameraUpdate(scrollTo: coord)
        mapView.moveCamera(cameraUpdate)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            store: store,
            selectedPlace: $selectedPlace,
            defaultMarkerImage: defaultMarker,
            selectedMarkerImage: selectedMarker
        )
    }
    
    func updateUIView(_ mapView: NMFMapView, context: Context) {
        mapView.touchDelegate = context.coordinator
        context.coordinator.updateMarkers(mapView: mapView, pickList: pickList, selectedPlaceId: selectedPlace?.placeId)
        
        if isLocationFocused, let userLocation = userLocation {
            let coord = NMGLatLng(lat: userLocation.coordinate.latitude, lng: userLocation.coordinate.longitude)
            let cameraUpdate = NMFCameraUpdate(scrollTo: coord, zoomTo: userLocationZoomLevel)
            cameraUpdate.animation = .easeIn
            cameraUpdate.animationDuration = 0.5
            mapView.moveCamera(cameraUpdate)
            
            context.coordinator.updateUserLocationMarker(mapView: mapView, location: userLocation)
        } else if let location = selectedLocation {
            let coord = NMGLatLng(lat: location.latitude, lng: location.longitude)
            let cameraUpdate = NMFCameraUpdate(scrollTo: coord, zoomTo: 11.0)
            cameraUpdate.animation = .easeIn
            cameraUpdate.animationDuration = 0.5
            mapView.moveCamera(cameraUpdate)
        }
        
        if context.coordinator.isInitialLoad && !pickList.isEmpty {
            let bounds = NMGLatLngBounds(latLngs: pickList.map {
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

final class Coordinator: NSObject, NMFMapViewTouchDelegate, UIGestureRecognizerDelegate {
    let store: StoreOf<MapFeature>
    @Binding var selectedPlace: CardPlace?
    var markers: [Int: NMFMarker] = [:]
    var isInitialLoad: Bool = true
    var userLocationMarker: NMFMarker?
    
    private var isProcessingMarkerTouch = false
    private var lastMarkerTouchTime: TimeInterval = 0
    
    private let defaultMarkerImage: NMFOverlayImage
    private let selectedMarkerImage: NMFOverlayImage
    
    init(store: StoreOf<MapFeature>,
         selectedPlace: Binding<CardPlace?>,
         defaultMarkerImage: NMFOverlayImage,
         selectedMarkerImage: NMFOverlayImage) {
        self.store = store
        self._selectedPlace = selectedPlace
        self.defaultMarkerImage = defaultMarkerImage
        self.selectedMarkerImage = selectedMarkerImage
        super.init()
    }
    
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
            
            self.store.send(.selectPlace(nil))
            self.store.send(.clearFocusedPlaces)
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
        
        if !pickList.isEmpty && isInitialLoad {
            adjustMapToShowAllMarkers(mapView, pickList: pickList)
        }
    }
    
    private func adjustMapToShowAllMarkers(_ mapView: NMFMapView, pickList: [PickListCardResponse]) {
        if pickList.count > 1 {
            let bounds = NMGLatLngBounds(latLngs: pickList.map {
                NMGLatLng(lat: $0.latitude, lng: $0.longitude)
            })
            let cameraUpdate = NMFCameraUpdate(fit: bounds, padding: 50)
            mapView.moveCamera(cameraUpdate)
        } else if let firstPlace = pickList.first {
            let coord = NMGLatLng(lat: firstPlace.latitude, lng: firstPlace.longitude)
            let cameraUpdate = NMFCameraUpdate(scrollTo: coord, zoomTo: 15.0)
            mapView.moveCamera(cameraUpdate)
        }
        
        isInitialLoad = false
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
        
        marker.userInfo = ["placeId": pickCard.placeId, "placeName": pickCard.placeName]
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
            
            guard let placeId = marker.userInfo["placeId"] as? Int else {
                self.isProcessingMarkerTouch = false
                return false
            }
            
            DispatchQueue.main.async {
                
                for (_, m) in self.markers {
                    m.iconImage = self.defaultMarkerImage
                }
                
                marker.iconImage = self.selectedMarkerImage
                
                self.store.send(.clearFocusedPlaces)
                self.store.send(.fetchFocusedPlace(placeId: placeId))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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

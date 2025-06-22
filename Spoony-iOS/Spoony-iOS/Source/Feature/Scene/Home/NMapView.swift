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
    private let districtZoomLevel: Double = 11.5    
    private let townZoomLevel: Double = 14.0        
    private let stationZoomLevel: Double = 15.0     
    
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
        
        setInitialCameraPosition(mapView)
        
        return mapView
    }
    
    private func setInitialCameraPosition(_ mapView: NMFMapView) {
        // 수정: 선택된 위치가 있으면 해당 위치로 초기 카메라 설정 (검색된 위치의 경우)
        if let selectedLocation = selectedLocation {
            let coord = NMGLatLng(lat: selectedLocation.latitude, lng: selectedLocation.longitude)
            // 검색된 위치는 역 수준으로 포커싱 (15배율)
            let cameraUpdate = NMFCameraUpdate(scrollTo: coord, zoomTo: stationZoomLevel)
            mapView.moveCamera(cameraUpdate)
            print("📍 초기 선택된 위치로 카메라 이동: \(selectedLocation) (줌: \(stationZoomLevel))")
            return
        }
        
        // 기존 로직: 사용자 위치 권한에 따른 카메라 설정
        let locationManager = CLLocationManager()
        
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            if let location = userLocation {
                let coord = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
                // 사용자 현재 위치는 역 수준으로 포커싱 (15배율)
                let cameraUpdate = NMFCameraUpdate(scrollTo: coord, zoomTo: stationZoomLevel)
                mapView.moveCamera(cameraUpdate)
                print("📍 초기 사용자 위치로 카메라 이동: \(location.coordinate) (줌: \(stationZoomLevel))")
            } else {
                moveCamera(mapView, to: NMGLatLng(lat: defaultLatitude, lng: defaultLongitude), zoom: districtZoomLevel)
            }
        case .denied, .restricted:
            moveCamera(mapView, to: NMGLatLng(lat: defaultLatitude, lng: defaultLongitude), zoom: districtZoomLevel)
        case .notDetermined:
            moveCamera(mapView, to: NMGLatLng(lat: defaultLatitude, lng: defaultLongitude), zoom: districtZoomLevel)
        @unknown default:
            moveCamera(mapView, to: NMGLatLng(lat: defaultLatitude, lng: defaultLongitude), zoom: districtZoomLevel)
        }
    }
    
    private func moveCamera(_ mapView: NMFMapView, to coord: NMGLatLng, zoom: Double = 11.5) {
        let cameraUpdate = NMFCameraUpdate(scrollTo: coord, zoomTo: zoom)
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

        let coordinator = context.coordinator
        
        // GPS 포커싱 시 사용자 위치로 이동 (역 수준 포커싱)
        if isLocationFocused, let userLocation = userLocation, !coordinator.hasMovedToUserLocation {
            let coord = NMGLatLng(lat: userLocation.coordinate.latitude, lng: userLocation.coordinate.longitude)
            let cameraUpdate = NMFCameraUpdate(scrollTo: coord, zoomTo: stationZoomLevel)
            cameraUpdate.animation = .easeIn
            cameraUpdate.animationDuration = 0.5
            mapView.moveCamera(cameraUpdate)
            
            coordinator.updateUserLocationMarker(mapView: mapView, location: userLocation)
            coordinator.hasMovedToUserLocation = true
            print("📍 사용자 위치로 카메라 이동 완료 (줌: \(stationZoomLevel))")
        }
        else if !isLocationFocused {
            coordinator.hasMovedToUserLocation = false
        }
        // 포커스된 장소가 있을 때 해당 위치로 이동 (동 수준 포커싱)
        else if let location = selectedLocation, !focusedPlaces.isEmpty, !coordinator.hasMovedToFocusedPlace {
            let coord = NMGLatLng(lat: location.latitude, lng: location.longitude)
            let cameraUpdate = NMFCameraUpdate(scrollTo: coord, zoomTo: townZoomLevel)
            cameraUpdate.animation = .easeIn
            cameraUpdate.animationDuration = 0.2
            mapView.moveCamera(cameraUpdate)
            coordinator.hasMovedToFocusedPlace = true
            print("📍 포커스된 장소로 카메라 이동 완료 (줌: \(townZoomLevel))")
        }
        else if focusedPlaces.isEmpty {
            coordinator.hasMovedToFocusedPlace = false
        }
        
        // 초기 로드 시 전체 픽리스트를 포함하는 영역으로 카메라 설정
        if coordinator.isInitialLoad && !pickList.isEmpty {
            let bounds = NMGLatLngBounds(latLngs: pickList.map {
                NMGLatLng(lat: $0.latitude, lng: $0.longitude)
            })
            let cameraUpdate = NMFCameraUpdate(fit: bounds, padding: 50)
            mapView.moveCamera(cameraUpdate)
            coordinator.isInitialLoad = false
            print("📍 초기 영역 설정 완료")
        }
    }
    
    private func configureMapView(context: Context) -> NMFMapView {
        let mapView = NMFMapView()
        mapView.positionMode = .normal
        mapView.zoomLevel = districtZoomLevel // 기본 줌 레벨을 구 수준으로 설정
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
    
    var hasMovedToUserLocation: Bool = false
    var hasMovedToFocusedPlace: Bool = false
    
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

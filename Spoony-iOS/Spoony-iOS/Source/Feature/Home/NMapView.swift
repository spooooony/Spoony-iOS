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
    @ObservedObject var viewModel: HomeViewModel
    @Binding var selectedPlace: CardPlace?
    
    private var mapView: NMFMapView
    let onMoveCamera: ((Double, Double) -> Void)?
        
    init(viewModel: HomeViewModel,
         selectedPlace: Binding<CardPlace?>,
         onMoveCamera: ((Double, Double) -> Void)? = nil) {
        self.viewModel = viewModel
        self._selectedPlace = selectedPlace
        self.onMoveCamera = onMoveCamera
        self.mapView = NMFMapView()
    }
    
    func makeUIView(context: Context) -> NMFMapView {
        let mapView = configureMapView(context: context)
        return mapView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(selectedPlace: $selectedPlace, defaultMarkerImage: defaultMarker)
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
        
        context.coordinator.markers = newMarkers

        if !viewModel.pickList.isEmpty {
            let bounds = NMGLatLngBounds(latLngs: viewModel.pickList.map {
                NMGLatLng(lat: $0.latitude, lng: $0.longitude)
            })
            let cameraUpdate = NMFCameraUpdate(fit: bounds, padding: 50)
            mapView.moveCamera(cameraUpdate)
        }
        
        if let location = viewModel.selectedLocation {
            let coord = NMGLatLng(lat: location.latitude, lng: location.longitude)
            let cameraUpdate = NMFCameraUpdate(scrollTo: coord)
            cameraUpdate.animation = .easeIn
            cameraUpdate.animationDuration = 0.2
            mapView.moveCamera(cameraUpdate)
        }
    }
    
    private func configureMapView(context: Context) -> NMFMapView {
        let mapView = NMFMapView()
        mapView.positionMode = .direction
        mapView.zoomLevel = defaultZoomLevel
        mapView.touchDelegate = context.coordinator
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
    private let defaultMarkerImage: NMFOverlayImage
    
    init(selectedPlace: Binding<CardPlace?>, defaultMarkerImage: NMFOverlayImage) {
        self._selectedPlace = selectedPlace
        self.defaultMarkerImage = defaultMarkerImage
    }
    
    func mapView(_ mapView: NMFMapView, didTap symbol: NMFSymbol) -> Bool {
        selectedPlace = nil
        return true
    }
    
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng) -> Bool {
        if selectedPlace != nil {
            selectedPlace = nil
            markers.forEach { marker in
                marker.mapView = nil
                marker.iconImage = defaultMarkerImage
                // 지도를 탭했을 때도 캡션 설정 유지
                marker.mapView = mapView
            }
            return true
        }
        return false
    }
}

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
        Coordinator(selectedPlace: $selectedPlace)
    }
    
    func updateUIView(_ mapView: NMFMapView, context: Context) {
        context.coordinator.markers.forEach { $0.mapView = nil }
        context.coordinator.markers.removeAll()
        
        let newMarkers = viewModel.pickList.map { pickCard in
            let marker = createMarker(for: pickCard)
            
            if let selected = selectedPlace, selected.placeId == pickCard.placeId {
                marker.iconImage = selectedMarker
                // 선택된 마커의 경우 캡션 표시
                configureSelectedMarkerCaption(marker, with: pickCard.placeName)
            } else {
                // 선택되지 않은 마커의 경우 캡션 숨김
                marker.captionText = ""
            }
            
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
            cameraUpdate.animationDuration = 0.5
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
    
    private func configureSelectedMarkerCaption(_ marker: NMFMarker, with placeName: String) {
        // 캡션 텍스트 설정
        marker.captionText = placeName
        
        // 캡션 스타일 설정
        marker.captionColor = .black
        marker.captionTextSize = 14
        marker.captionMinZoom = 0
        marker.captionMaxZoom = 20
        
        // 캡션 위치 및 여백 설정
        marker.captionOffset = -16
        marker.captionAligns = [NMFAlignType.bottom]
    }
    
    private func createMarker(for pickCard: PickListCardResponse) -> NMFMarker {
        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: pickCard.latitude, lng: pickCard.longitude)
        marker.iconImage = defaultMarker
        marker.width = CGFloat(NMF_MARKER_SIZE_AUTO)
        marker.height = CGFloat(NMF_MARKER_SIZE_AUTO)
        
        marker.touchHandler = { [weak viewModel, weak marker] (_) -> Bool in
            guard let marker = marker else { return false }
            
            let currentlySelected = (marker.iconImage == selectedMarker)
            
            if !currentlySelected {
                marker.iconImage = selectedMarker
                configureSelectedMarkerCaption(marker, with: pickCard.placeName)
                viewModel?.fetchFocusedPlace(placeId: pickCard.placeId)
            } else {
                selectedPlace = nil
                marker.iconImage = defaultMarker
                marker.captionText = "" // 캡션 제거
            }
            
            return true
        }
        
        if let selected = selectedPlace, selected.placeId == pickCard.placeId {
            marker.iconImage = selectedMarker
            configureSelectedMarkerCaption(marker, with: pickCard.placeName)
        }
        
        return marker
    }
}

final class Coordinator: NSObject, NMFMapViewTouchDelegate {
    @Binding var selectedPlace: CardPlace?
    var markers: [NMFMarker] = []
    
    init(selectedPlace: Binding<CardPlace?>) {
        self._selectedPlace = selectedPlace
    }
    
    func mapView(_ mapView: NMFMapView, didTap symbol: NMFSymbol) -> Bool {
        selectedPlace = nil
        return true
    }
    
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng) -> Bool {
        if selectedPlace != nil {
            selectedPlace = nil
            markers.forEach { marker in
                marker.iconImage = NMFOverlayImage(name: "ic_unselected_marker")
                marker.captionText = "" // 캡션 제거
            }
            return true
        }
        return false
    }
}

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
    }
    
    private func configureMapView(context: Context) -> NMFMapView {
        let mapView = NMFMapView()
        mapView.positionMode = .direction
        mapView.zoomLevel = defaultZoomLevel
        mapView.touchDelegate = context.coordinator
        return mapView
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
                viewModel?.fetchFocusedPlace(placeId: pickCard.placeId)
            } else {
                selectedPlace = nil
                marker.iconImage = defaultMarker
            }
            
            return true
        }
        
        if let selected = selectedPlace, selected.placeId == pickCard.placeId {
            marker.iconImage = selectedMarker
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
}

//
//  NMapView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/14/25.
//

import SwiftUI
import NMapsMap

import SwiftUI
import NMapsMap

struct NMapView: UIViewRepresentable {
    private let defaultZoomLevel: Double = 11.5
    private let defaultMarker = NMFOverlayImage(name: "ic_unselected_marker")
    private let selectedMarker = NMFOverlayImage(name: "ic_selected_marker")
    private let defaultMarkerSize = (width: 40.adjusted, height: 58.adjustedH)
    private let selectedMarkerSize = (width: 30.adjusted, height: 30.adjustedH)
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
        // 기존 마커들 제거
        context.coordinator.markers.forEach { $0.mapView = nil }
        context.coordinator.markers.removeAll()
        
        // 새로운 마커들 추가
        for pickCard in viewModel.pickList {
            let marker = createMarker(for: pickCard)
            marker.mapView = mapView
            context.coordinator.markers.append(marker)
        }
        
        // 모든 마커가 보이도록 카메라 이동
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
        marker.width = CGFloat((NMF_MARKER_SIZE_AUTO))
        marker.height = CGFloat((NMF_MARKER_SIZE_AUTO))
        
        var isSelected = false
        marker.touchHandler = { (_) -> Bool in
            isSelected.toggle()
            if isSelected {
                marker.iconImage = selectedMarker
                marker.width = selectedMarkerSize.width
                marker.height = selectedMarkerSize.height
                viewModel.fetchFocusedPlace(placeId: pickCard.placeId)
            } else {
                marker.iconImage = defaultMarker
                marker.width = defaultMarkerSize.width
                marker.height = defaultMarkerSize.height
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
    
    init(selectedPlace: Binding<CardPlace?>) {
        self._selectedPlace = selectedPlace
    }
    
    func mapView(_ mapView: NMFMapView, didTap symbol: NMFSymbol) -> Bool {
        selectedPlace = nil
        return true
    }
}

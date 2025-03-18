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
        // 마커 관리를 위한 Coordinator 설정
        mapView.touchDelegate = context.coordinator
        
        // 마커 업데이트 작업을 수행합니다.
        context.coordinator.updateMarkers(mapView: mapView, pickList: viewModel.pickList, selectedPlaceId: selectedPlace?.placeId)
        
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
    
    private func configureMapView(context: Context) -> NMFMapView {
        let mapView = NMFMapView()
        mapView.positionMode = .disabled
        mapView.zoomLevel = defaultZoomLevel
        mapView.touchDelegate = context.coordinator
        mapView.logoAlign = .rightTop
        mapView.logoInteractionEnabled = true
        mapView.logoMargin = UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 12)
        
        // 지도 터치 이벤트 설정
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleMapTap(_:)))
        tapGesture.delegate = context.coordinator
        mapView.addGestureRecognizer(tapGesture)
        
        return mapView
    }
}

final class Coordinator: NSObject, NMFMapViewTouchDelegate, UIGestureRecognizerDelegate {
    @Binding var selectedPlace: CardPlace?
    var markers: [Int: NMFMarker] = [:] // placeId를 키로 사용하는 딕셔너리로 변경
    var isInitialLoad: Bool = true
    
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
    
    // 제스처 인식기 처리
    @objc func handleMapTap(_ gesture: UITapGestureRecognizer) {
        print("지도 터치 감지됨")
        
        // UI 업데이트는 메인 스레드에서 수행
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 모든 마커 초기화
            for (_, marker) in self.markers {
                if let placeName = marker.userInfo["placeName"] as? String {
                    marker.iconImage = self.defaultMarkerImage
                    self.configureMarkerCaption(marker, with: placeName, isSelected: false)
                }
            }
            
            // 선택된 장소 초기화
            self.selectedPlace = nil
            
            // ViewModel 메서드 호출을 메인 스레드에서 수행
            if !self.viewModel.focusedPlaces.isEmpty {
                self.viewModel.clearFocusedPlaces()
            }
        }
    }
    
    // UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // 성능 최적화: 마커 업데이트 로직
    func updateMarkers(mapView: NMFMapView, pickList: [PickListCardResponse], selectedPlaceId: Int?) {
        // 현재 표시된 마커들의 ID 집합
        var currentMarkerIds = Set(markers.keys)
        
        // 새로운 마커 추가 또는 기존 마커 업데이트
        for pickCard in pickList {
            let placeId = pickCard.placeId
            let isSelected = placeId == selectedPlaceId
            
            if let existingMarker = markers[placeId] {
                // 기존 마커 업데이트
                updateMarker(existingMarker, with: pickCard, isSelected: isSelected)
                currentMarkerIds.remove(placeId)
            } else {
                // 새 마커 생성
                let newMarker = createMarker(for: pickCard, isSelected: isSelected, mapView: mapView)
                newMarker.mapView = mapView
                markers[placeId] = newMarker
            }
        }
        
        // 제거해야 할 마커들 처리
        for idToRemove in currentMarkerIds {
            if let markerToRemove = markers[idToRemove] {
                markerToRemove.mapView = nil
                markers.removeValue(forKey: idToRemove)
            }
        }
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
        
        // 마커에 장소 ID 정보 저장
        marker.userInfo = ["placeId": pickCard.placeId, "placeName": pickCard.placeName]
        
        configureMarkerCaption(marker, with: pickCard.placeName, isSelected: isSelected)
        
        // 마커 터치 이벤트 설정
        marker.touchHandler = { [weak self, unowned mapView] _ -> Bool in
            guard let self = self else { return false }
            guard let placeId = marker.userInfo["placeId"] as? Int,
                  let placeName = marker.userInfo["placeName"] as? String else { return false }
            
            // 현재 선택 상태 확인
            let isCurrentlySelected = (self.selectedPlace?.placeId == placeId)
            
            // UI 업데이트는 메인 스레드에서 수행
            DispatchQueue.main.async {
                if !isCurrentlySelected {
                    // 새로운 마커 선택
                    marker.iconImage = self.selectedMarkerImage
                    self.configureMarkerCaption(marker, with: placeName, isSelected: true)
                    self.viewModel.fetchFocusedPlace(placeId: placeId)
                } else {
                    // 선택 해제
                    marker.iconImage = self.defaultMarkerImage
                    self.configureMarkerCaption(marker, with: placeName, isSelected: false)
                    self.selectedPlace = nil
                    self.viewModel.clearFocusedPlaces()
                }
            }
            
            return true
        }
        
        return marker
    }
    
    // NMFMapViewTouchDelegate
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng) -> Bool {
        // 기본 터치 이벤트는 UITapGestureRecognizer에서 처리
        return false
    }
}

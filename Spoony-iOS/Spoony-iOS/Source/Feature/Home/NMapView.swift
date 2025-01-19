//
//  NMapView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/14/25.
//

import SwiftUI
import NMapsMap

struct NMapView: UIViewRepresentable {
    func makeUIView(context: Context) -> NMFMapView {
        let mapView = NMFMapView()
        mapView.positionMode = .direction
        mapView.zoomLevel = 15
        
        //시청으로 임시 고정
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: 37.5666102, lng: 126.9783881))
        mapView.moveCamera(cameraUpdate)
        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: 37.5666102, lng: 126.9783881)
        marker.width = 120
        marker.height = 120
        marker.iconImage = NMFOverlayImage(name: "makerTest")
        marker.iconImage = NMFOverlayImage(name: "makerTest")

        marker.mapView = mapView
        
        return mapView
    }
    
    // todo: 기본 Protocol. 추후 이벤트 발생시 구현 예정
    func updateUIView(_ uiView: NMFMapView, context: Context) {
    }
}

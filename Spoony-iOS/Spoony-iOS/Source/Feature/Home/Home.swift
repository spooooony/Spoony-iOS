//
//  Home.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/2/25.
//

import SwiftUI
import NMapsMap

struct Home: View {
    
    @EnvironmentObject private var navigationManager: NavigationManager
    
    var body: some View {
        ZStack(alignment: .top) {
            NMapView()
                .edgesIgnoringSafeArea(.all)

        }
    }
}

struct NMapView: UIViewRepresentable {
    func makeUIView(context: Context) -> NMFMapView {
        let mapView = NMFMapView()
        mapView.positionMode = .direction
        mapView.zoomLevel = 15
        
        //시청으로 임시 고정
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: 37.5666102, lng: 126.9783881))
        mapView.moveCamera(cameraUpdate)
        
        return mapView
    }
    
    func updateUIView(_ uiView: NMFMapView, context: Context) {
    }
}

#Preview {
    Home()
        .environmentObject(NavigationManager())
}

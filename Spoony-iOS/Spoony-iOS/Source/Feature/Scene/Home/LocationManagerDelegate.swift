//
//  LocationManagerDelegate.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/14/25.
//

import Foundation
import CoreLocation

/// CLLocationManagerDelegate를 구현하는 클래스
/// 위치 업데이트를 받아서 클로저로 전달
final class LocationManagerDelegate: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let onLocationUpdate: (CLLocation) -> Void
    
    init(onLocationUpdate: @escaping (CLLocation) -> Void) {
        self.onLocationUpdate = onLocationUpdate
        super.init()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print(location)
        onLocationUpdate(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // 권한 변경 처리
    }
}

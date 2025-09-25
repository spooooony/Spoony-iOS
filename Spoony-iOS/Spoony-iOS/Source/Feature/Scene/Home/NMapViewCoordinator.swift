//
//  NMapViewCoordinator.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/14/25.
//

import Foundation
import NMapsMap
import ComposableArchitecture
import CoreLocation
import SwiftUI

/**
 * NMapViewCoordinator
 *
 * UIViewRepresentable의 Coordinator 클래스로, UIKit과 SwiftUI 간의 통신을 담당합니다.
 * 네이버 지도의 델리게이트 메서드를 구현하고, SwiftUI의 상태를 업데이트합니다.
 *
 * ## 주요 역할
 * 1. **이벤트 처리**
 *    - 마커 터치 이벤트
 *    - 지도 탭 이벤트
 *    - 제스처 인식
 *
 * 2. **마커 관리**
 *    - 픽리스트 마커 생성/업데이트/삭제
 *    - 사용자 위치 마커 관리
 *    - 마커 선택 상태 관리
 *
 * 3. **상태 동기화**
 *    - SwiftUI @Binding 업데이트
 *    - TCA Store로 액션 전송
 *    - 상태 플래그 관리
 *
 * ## 아키텍처 위치
 * ```
 * SwiftUI View
 *      ↓
 * UIViewRepresentable (NMapView)
 *      ↓
 * Coordinator (NMapViewCoordinator) ← 현재 클래스
 *      ↓
 * UIKit View (NMFMapView)
 * ```
 *
 * ## 생명주기
 * - 생성: makeCoordinator()에서 생성
 * - 유지: 뷰가 화면에 있는 동안 유지
 * - 해제: 뷰가 사라질 때 자동 해제
 *
 * ## 메모리 관리
 * - weak self 사용으로 순환 참조 방지
 * - 마커 딕셔너리로 효율적 관리
 * - 비동기 작업에 DispatchQueue 활용
 */
final class NMapViewCoordinator: NSObject {
    
    // MARK: - Properties
    
    /**
     * TCA Store 참조
     *
     * - 타입: StoreOf<MapFeature>
     * - 역할: 지도 관련 액션을 Store로 전송
     * - 주요 액션:
     *   - selectPlace: 장소 선택
     *   - clearFocusedPlaces: 포커스 해제
     *   - fetchFocusedPlace: 특정 장소 포커싱
     * - 참조 타입: 강한 참조 (retain)
     * - 주의: 순환 참조 방지를 위해 클로저에서 weak self 사용
     */
    let store: StoreOf<MapFeature>
    
    /**
     * 선택된 장소 바인딩
     *
     * - 타입: @Binding<CardPlace?>
     * - 역할: SwiftUI View와 양방향 데이터 동기화
     * - 업데이트 시점:
     *   - 마커 터치: 해당 장소로 업데이트
     *   - 지도 탭: nil로 업데이트 (선택 해제)
     *   - 외부 변경: 자동으로 UI 업데이트
     * - 주의: Main thread에서만 업데이트
     */
    @Binding var selectedPlace: CardPlace?
    
    // MARK: - Marker Management
    
    /**
     * 픽리스트 마커 딕셔너리
     *
     * - 타입: [Int: NMFMarker]
     * - 키: placeId (장소 고유 ID)
     * - 값: NMFMarker 인스턴스
     * - 용도: 효율적인 마커 검색 및 업데이트
     * - 크기: 픽리스트 장소 수와 동일 (최대 약 100개)
     * - 업데이트: updateMarkers 메서드에서 관리
     * - 메모리: 마커 제거 시 딕셔너리에서도 삭제
     */
    var markers: [Int: NMFMarker] = [:]
    
    /**
     * 사용자 위치 마커
     *
     * - 타입: NMFMarker? (옵셔널)
     * - 아이콘: ic_my_location (파란색 현재 위치)
     * - nil 조건:
     *   - 위치 권한 없음
     *   - GPS 비활성
     *   - 아직 생성되지 않음
     * - 업데이트: GPS 신호에 따라 실시간 위치 변경
     * - 특징: 다른 마커와 독립적으로 관리
     */
    var userLocationMarker: NMFMarker?
    
    // MARK: - State Flags
    
    /**
     * 초기 로드 플래그
     *
     * - 초기값: true
     * - true: 지도가 처음 로드됨, 전체 영역 표시 필요
     * - false: 초기 영역 설정 완료
     * - 변경 시점: setInitialBounds 호출 후 false로 변경
     * - 목적: 불필요한 카메라 이동 방지
     */
    var isInitialLoad: Bool = true
    
    /**
     * 사용자 위치 이동 완료 플래그
     *
     * - 초기값: false
     * - true: GPS 포커싱으로 사용자 위치 이동 완료
     * - false: 아직 이동하지 않음 또는 GPS 비활성
     * - 리셋: isLocationFocused가 false가 될 때
     * - 목적: GPS 버튼 토글 시 중복 이동 방지
     */
    var hasMovedToUserLocation: Bool = false
    
    /**
     * 포커스 장소 이동 완료 플래그
     *
     * - 초기값: false
     * - true: 선택된 장소로 카메라 이동 완료
     * - false: 아직 이동하지 않음
     * - 리셋: focusedPlaces가 비어있을 때
     * - 목적: 같은 장소로 반복 이동 방지
     */
    var hasMovedToFocusedPlace: Bool = false
    
    // MARK: - Touch Handling
    
    /**
     * 마커 터치 처리 중 플래그
     *
     * - 타입: Bool
     * - 초기값: false
     * - true: 현재 마커 터치 이벤트 처리 중
     * - false: 대기 상태
     * - 목적: 연속된 터치 이벤트 방지 (더블 탭 등)
     * - 리셋: 0.5초 후 자동 리셋
     * - 접근 제한: internal (Extension에서 접근 가능)
     */
    var isProcessingMarkerTouch = false
    
    /**
     * 마지막 마커 터치 시간
     *
     * - 타입: TimeInterval (Double)
     * - 단위: 초 (seconds)
     * - 초기값: 0
     * - 용도: 디바운싱 처리를 위한 시간 기록
     * - 현재 미사용: 필요 시 활용 가능
     * - 예시: 0.3초 이내 재터치 무시
     */
    var lastMarkerTouchTime: TimeInterval = 0
    
    // MARK: - Image Resources
    
    /**
     * 기본 마커 이미지
     *
     * - 타입: NMFOverlayImage
     * - Asset: "ic_unselected_marker"
     * - 색상: 회색 또는 연한 색상
     * - 사용: 선택되지 않은 마커
     * - 참조: MapConstants에서 가져옴
     * - 접근 제한: internal (Extension에서 접근 가능)
     */
    let defaultMarkerImage = MapConstants.MarkerImage.defaultMarker
    
    /**
     * 선택된 마커 이미지
     *
     * - 타입: NMFOverlayImage
     * - Asset: "ic_selected_marker"
     * - 색상: 앱 테마 색상 (Primary Color)
     * - 사용: 사용자가 선택한 마커
     * - 크기: 기본 마커와 동일
     * - 참조: MapConstants에서 가져옴
     */
    let selectedMarkerImage = MapConstants.MarkerImage.selectedMarker
    
    // MARK: - Initialization
    
    /**
     * Coordinator 초기화자
     *
     * NMapViewCoordinator 인스턴스를 생성하고 필수 속성들을 초기화합니다.
     *
     * ## 호출 시점
     * - NMapView.makeCoordinator()에서 호출
     * - UIView 생성 전에 호출됨
     *
     * ## 초기화 작업
     * 1. Store 참조 저장
     * 2. Binding 프로퍼티 연결
     * 3. NSObject 초기화 (super.init)
     *
     * ## 메모리 관리
     * - Store는 강한 참조로 보관
     * - Binding은 @propertyWrapper로 자동 관리
     *
     * @param store MapFeature를 관리하는 TCA Store
     *              - 지도 상태 관리
     *              - 액션 처리
     *              - 사이드 이펙트 수행
     *
     * @param selectedPlace 선택된 장소에 대한 양방향 바인딩
     *                      - SwiftUI View와 동기화
     *                      - nil: 선택 없음
     *                      - 값: 해당 장소 선택
     */
    init(store: StoreOf<MapFeature>,
         selectedPlace: Binding<CardPlace?>) {
        self.store = store
        self._selectedPlace = selectedPlace
        super.init()
    }
    
    // MARK: - User Location
    
    /**
     * 사용자 위치 마커 업데이트
     *
     * GPS로 받은 사용자의 현재 위치를 지도에 표시하거나 업데이트합니다.
     *
     * ## 동작 방식
     * 1. 마커가 없으면 새로 생성
     * 2. 마커가 있으면 위치만 업데이트
     * 3. 파란색 현재 위치 아이콘 사용
     *
     * ## 호출 시점
     * - GPS 포커싱 활성 시
     * - 위치 정보 업데이트 시
     * - 초기 위치 설정 시
     *
     * ## 마커 설정
     * - 아이콘: ic_my_location
     * - 크기: NMF_MARKER_SIZE_AUTO (자동)
     * - 위치: 사용자 현재 좌표
     * - 터치: 불가 (선택 불가능)
     *
     * @param mapView 마커를 추가할 지도 뷰
     * @param location 사용자의 현재 위치 정보
     *                 - coordinate: 위도/경도
     *                 - accuracy: 정확도
     *                 - timestamp: 측정 시간
     */
    func updateUserLocationMarker(mapView: NMFMapView, location: CLLocation) {
        // 마커가 없으면 생성
        if userLocationMarker == nil {
            userLocationMarker = createUserLocationMarker(mapView: mapView)
        }
        
        // 위치 업데이트
        userLocationMarker?.position = NMGLatLng(
            lat: location.coordinate.latitude,
            lng: location.coordinate.longitude
        )
    }
    
    /**
     * 사용자 위치 마커 생성
     *
     * 새로운 사용자 위치 마커를 생성하고 초기 설정을 수행합니다.
     *
     * ## 마커 속성
     * - 아이콘: MapConstants.MarkerImage.userLocation
     * - 크기: 자동 크기 (NMF_MARKER_SIZE_AUTO)
     * - 색상: 파란색 (일반적인 GPS 표시 색상)
     * - 터치 불가: 사용자 위치는 선택 불가
     * - 캡션 없음: 텍스트 라벨 표시 안 함
     *
     * ## 생명주기
     * - 생성: updateUserLocationMarker에서 처음 호출 시
     * - 유지: userLocationMarker 프로퍼티에 저장
     * - 제거: 지도가 사라질 때 자동 제거
     *
     * @param mapView 마커를 추가할 지도 뷰
     * @return 생성된 사용자 위치 마커 인스턴스
     */
    private func createUserLocationMarker(mapView: NMFMapView) -> NMFMarker {
        let marker = NMFMarker()
        marker.iconImage = MapConstants.MarkerImage.userLocation
        marker.width = CGFloat(NMF_MARKER_SIZE_AUTO)
        marker.height = CGFloat(NMF_MARKER_SIZE_AUTO)
        marker.mapView = mapView
        return marker
    }
}

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

/**
 * NMapView
 *
 * 네이버 지도를 SwiftUI에서 사용하기 위한 UIViewRepresentable 구현체입니다.
 * UIKit 기반의 NMFMapView를 SwiftUI 환경에서 사용할 수 있도록 브릿지 역할을 수행합니다.
 *
 * ## 아키텍처 통합
 * - TCA(The Composable Architecture)와 완전히 통합되어 작동
 * - Store를 통해 상태 관리 및 액션 처리
 * - 단방향 데이터 플로우 보장
 *
 * ## 주요 기능
 * 1. **지도 초기화 및 설정**
 *    - 네이버 지도 SDK 초기화
 *    - 초기 카메라 위치 설정 (우선순위: 선택 위치 > 사용자 위치 > 기본 위치)
 *    - 지도 UI 컨트롤 설정 (로고, 줌 버튼 등)
 *
 * 2. **마커 관리**
 *    - 픽리스트 장소들을 마커로 표시
 *    - 마커 선택/해제 상태 관리
 *    - 마커 캡션(라벨) 표시 제어
 *    - 사용자 위치 마커 별도 관리
 *
 * 3. **카메라 제어**
 *    - GPS 버튼 탭 시 사용자 위치로 이동
 *    - 장소 선택 시 해당 위치로 포커싱
 *    - 검색 결과 위치로 자동 이동
 *    - 애니메이션 효과 적용
 *
 * 4. **인터랙션 처리**
 *    - 마커 탭 이벤트 처리
 *    - 지도 탭으로 선택 해제
 *    - 제스처 충돌 방지
 *
 * ## 데이터 플로우
 * ```
 * SwiftUI View → NMapView → Coordinator → TCA Store
 *                    ↑                          ↓
 *                    └──────── State ←──────────┘
 * ```
 *
 * ## 사용 예시
 * ```swift
 * NMapView(
 *     store: store,
 *     selectedPlace: $selectedPlace,
 *     isLocationFocused: isGPSFocused,
 *     userLocation: locationManager.location,
 *     focusedPlaces: focusedPlaces,
 *     pickList: pickList,
 *     selectedLocation: searchedLocation
 * )
 * ```
 *
 * ## 주의사항
 * - 네이버 지도 SDK 초기화가 AppDelegate에서 완료되어야 함
 * - 위치 권한 요청은 별도로 처리해야 함
 * - 메모리 관리를 위해 weak reference 사용 권장
 */
struct NMapView: UIViewRepresentable {
    
    // MARK: - Properties
    
    /**
     * TCA Store 참조
     *
     * - 타입: StoreOf<MapFeature>
     * - 역할: 지도 관련 모든 상태와 액션을 중앙에서 관리
     * - 포함 내용:
     *   - 마커 선택 상태
     *   - 포커스된 장소 정보
     *   - 로딩 상태
     *   - 에러 처리
     * - 통신: Coordinator를 통해 액션 전송
     */
    let store: StoreOf<MapFeature>
    
    /**
     * 현재 선택된 장소
     *
     * - 타입: @Binding<CardPlace?>
     * - 역할: 부모 뷰와 양방향 데이터 바인딩
     * - nil: 선택된 장소 없음
     * - 값 있음: 해당 장소가 선택됨 (마커 강조, 카드 표시)
     * - 변경 시점:
     *   - 마커 탭: 해당 장소로 변경
     *   - 지도 탭: nil로 변경 (선택 해제)
     *   - 카드 스와이프: 해당 카드의 장소로 변경
     */
    @Binding var selectedPlace: CardPlace?
    
    /**
     * GPS 포커싱 상태
     *
     * - 타입: Bool
     * - true: GPS 버튼이 활성화되어 사용자 위치 추적 중
     * - false: GPS 추적 비활성
     * - 동작:
     *   - true 전환 시: 사용자 위치로 카메라 이동 (애니메이션)
     *   - false 전환 시: 추적 중단, 자유 이동 가능
     * - UI 반영: GPS 버튼 색상 변경으로 상태 표시
     */
    let isLocationFocused: Bool
    
    /**
     * 사용자 현재 위치
     *
     * - 타입: CLLocation? (옵셔널)
     * - 제공 정보:
     *   - coordinate: 위도/경도
     *   - altitude: 고도
     *   - accuracy: 정확도
     *   - timestamp: 측정 시간
     * - nil 조건:
     *   - 위치 권한 거부
     *   - GPS 신호 없음
     *   - 위치 서비스 비활성
     * - 업데이트: LocationManager에서 실시간 제공
     */
    let userLocation: CLLocation?
    
    /**
     * 포커스된 장소 목록
     *
     * - 타입: [CardPlace]
     * - 용도: 검색 결과나 필터링된 장소들을 강조 표시
     * - 빈 배열: 특별히 포커스할 장소 없음
     * - 값 있음: 해당 장소들만 강조, 나머지는 흐리게 표시
     * - 사용 케이스:
     *   - 검색 결과 표시
     *   - 카테고리 필터링
     *   - 추천 장소 하이라이트
     */
    let focusedPlaces: [CardPlace]
    
    /**
     * 픽리스트 카드 데이터
     *
     * - 타입: [PickListCardResponse]
     * - 내용: 서버에서 받은 모든 픽리스트 장소 정보
     * - 포함 정보:
     *   - placeId: 장소 고유 ID
     *   - placeName: 장소명
     *   - latitude/longitude: 좌표
     *   - category: 카테고리
     *   - imageUrl: 대표 이미지
     * - 용도: 지도에 마커로 표시할 모든 장소 데이터
     * - 업데이트: API 호출 시 갱신
     */
    let pickList: [PickListCardResponse]
    
    /**
     * 선택된 특정 위치 좌표
     *
     * - 타입: (latitude: Double, longitude: Double)? (튜플, 옵셔널)
     * - 용도: 검색이나 외부에서 지정한 특정 위치로 이동
     * - nil: 특별히 지정된 위치 없음
     * - 값 있음: 해당 좌표로 카메라 초기 위치 설정
     * - 사용 케이스:
     *   - 주소 검색 결과 위치
     *   - 딥링크로 전달받은 위치
     *   - 다른 화면에서 선택한 위치
     * - 우선순위: 가장 높음 (사용자 위치보다 우선)
     */
    let selectedLocation: (latitude: Double, longitude: Double)?
    
    // MARK: - UIViewRepresentable
    
    /**
     * UIView 생성 메서드
     *
     * UIViewRepresentable 프로토콜의 필수 메서드로, 지도 뷰를 생성하고 초기화합니다.
     *
     * ## 호출 시점
     * - SwiftUI 뷰가 처음 렌더링될 때 한 번만 호출
     * - 뷰가 재생성되어도 기존 인스턴스 재사용
     *
     * ## 수행 작업
     * 1. NMFMapView 인스턴스 생성
     * 2. 지도 기본 설정 (줌 레벨, 위치 모드 등)
     * 3. 로고 위치 및 레이아웃 조정
     * 4. 터치 델리게이트 설정
     * 5. 탭 제스처 추가
     * 6. 초기 카메라 위치 설정
     *
     * @param context UIViewRepresentable Context (코디네이터 포함)
     * @return 초기화된 NMFMapView 인스턴스
     */
    func makeUIView(context: Context) -> NMFMapView {
        let mapView = NMFMapView()
        
        // 지도 기본 설정
        mapView.positionMode = .normal
        mapView.zoomLevel = MapConstants.ZoomLevel.district
        mapView.touchDelegate = context.coordinator
        
        // 네이버 로고 위치 조정 (칩 영역 아래로)
        mapView.logoAlign = .rightTop
        mapView.logoInteractionEnabled = true
        mapView.logoMargin = UIEdgeInsets(
            top: MapConstants.Layout.chipAreaHeight.adjustedH,
            left: 0,
            bottom: 0,
            right: MapConstants.Layout.logoRightMargin
        )
        
        // 맵 탭 제스처 추가 (마커 선택 해제용)
        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(NMapViewCoordinator.handleMapTap(_:))
        )
        tapGesture.delegate = context.coordinator
        mapView.addGestureRecognizer(tapGesture)
        
        // 초기 카메라 위치 설정
        setupInitialCamera(for: mapView)
        
        return mapView
    }
    
    /**
     * UIView 업데이트 메서드
     *
     * SwiftUI 상태가 변경될 때마다 호출되어 지도를 업데이트합니다.
     *
     * ## 호출 시점
     * - @State, @Binding 등의 상태 변경 시
     * - 부모 뷰 리렌더링 시
     * - 프로퍼티 값 변경 시
     *
     * ## 수행 작업
     * 1. 터치 델리게이트 재설정 (안전성 보장)
     * 2. 마커 업데이트
     *    - 픽리스트 기반 마커 추가/제거/업데이트
     *    - 선택 상태 반영
     * 3. 카메라 업데이트
     *    - GPS 포커싱 처리
     *    - 장소 포커싱 처리
     *    - 초기 영역 설정
     *
     * ## 최적화
     * - 불필요한 업데이트 방지를 위해 플래그 사용
     * - 비동기 작업은 DispatchQueue 활용
     *
     * @param mapView 업데이트할 지도 뷰 인스턴스
     * @param context UIViewRepresentable Context (코디네이터 포함)
     */
    func updateUIView(_ mapView: NMFMapView, context: Context) {
        let coordinator = context.coordinator
        
        // 터치 델리게이트 재설정 (안전성 보장)
        mapView.touchDelegate = coordinator
        
        // 마커 업데이트
        coordinator.updateMarkers(
            mapView: mapView,
            pickList: pickList,
            selectedPlaceId: selectedPlace?.placeId
        )
        
        // 카메라 업데이트 처리
        handleCameraUpdates(mapView: mapView, coordinator: coordinator)
    }
    
    /**
     * Coordinator 생성 메서드
     *
     * UIKit의 델리게이트 패턴과 SwiftUI의 데이터 바인딩을 연결하는 코디네이터를 생성합니다.
     *
     * ## Coordinator 역할
     * - UIKit 델리게이트 메서드 구현
     * - SwiftUI @Binding 프로퍼티 업데이트
     * - TCA Store로 액션 전송
     * - 마커 및 제스처 관리
     *
     * ## 생명주기
     * - makeUIView보다 먼저 호출
     * - 뷰가 사라질 때까지 유지
     * - 강한 참조로 보관 (retain)
     *
     * @return NMapViewCoordinator 인스턴스
     */
    func makeCoordinator() -> NMapViewCoordinator {
        NMapViewCoordinator(
            store: store,
            selectedPlace: $selectedPlace
        )
    }
    
    // MARK: - Private Methods
    
    /**
     * 초기 카메라 위치 설정
     *
     * 지도가 처음 로드될 때 카메라의 초기 위치를 결정합니다.
     *
     * ## 우선순위 (높음 → 낮음)
     * 1. **selectedLocation** (가장 높음)
     *    - 검색으로 선택한 위치
     *    - 딥링크로 전달받은 위치
     *    - 줌 레벨: station (15.0)
     *
     * 2. **userLocation** (중간)
     *    - 위치 권한이 허용된 경우
     *    - GPS로 받은 현재 위치
     *    - 줌 레벨: station (15.0)
     *
     * 3. **defaultLocation** (가장 낮음)
     *    - 서울 중심부 고정 위치
     *    - 위치 정보가 없을 때 폴백
     *    - 줌 레벨: district (11.5)
     *
     * ## 위치 권한 처리
     * - authorizedWhenInUse/Always: 사용자 위치 사용
     * - denied/restricted: 기본 위치 사용
     * - notDetermined: 기본 위치 사용 (권한 요청 전)
     *
     * @param mapView 초기화할 지도 뷰
     */
    private func setupInitialCamera(for mapView: NMFMapView) {
        // 1. 선택된 위치가 있으면 해당 위치로 이동 (검색 결과 등)
        if let selectedLocation = selectedLocation {
            moveCameraToLocation(
                mapView,
                latitude: selectedLocation.latitude,
                longitude: selectedLocation.longitude,
                zoom: MapConstants.ZoomLevel.station
            )
            return
        }
        
        // 2. 사용자 위치 권한 확인 및 처리
        let locationManager = CLLocationManager()
        
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // 권한이 있고 위치 정보가 있으면 사용자 위치로
            if let location = userLocation {
                moveCameraToLocation(
                    mapView,
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    zoom: MapConstants.ZoomLevel.station
                )
            } else {
                // 위치 정보가 없으면 기본 위치로
                moveToDefaultLocation(mapView)
            }
            
        case .denied, .restricted, .notDetermined:
            // 권한이 없으면 기본 위치로
            moveToDefaultLocation(mapView)
            
        @unknown default:
            moveToDefaultLocation(mapView)
        }
    }
    
    /**
     * 기본 위치로 카메라 이동
     *
     * 사용자 위치를 사용할 수 없을 때 서울 중심부로 카메라를 이동시킵니다.
     *
     * ## 사용 시나리오
     * - 위치 권한 거부
     * - GPS 신호 없음
     * - 위치 서비스 비활성
     * - 앱 최초 실행
     *
     * ## 설정값
     * - 위치: 서울시청 인근 (37.5563, 126.9236)
     * - 줌 레벨: district (11.5) - 구 전체가 보이는 수준
     * - 애니메이션: 없음 (즉시 이동)
     *
     * @param mapView 카메라를 이동시킬 지도 뷰
     */
    private func moveToDefaultLocation(_ mapView: NMFMapView) {
        moveCameraToLocation(
            mapView,
            latitude: MapConstants.DefaultLocation.latitude,
            longitude: MapConstants.DefaultLocation.longitude,
            zoom: MapConstants.ZoomLevel.district
        )
    }
    
    /**
     * 지정된 좌표로 카메라 이동
     *
     * 특정 위도/경도로 지도 카메라를 이동시키는 헬퍼 메서드입니다.
     *
     * ## 애니메이션 효과
     * - animated = false: 즉시 이동 (깜빡임)
     * - animated = true: 부드러운 이동 (easeIn)
     *
     * ## 사용 예시
     * ```swift
     * // 즉시 이동
     * moveCameraToLocation(mapView, 
     *                     latitude: 37.5665, 
     *                     longitude: 126.9780,
     *                     zoom: 15.0)
     *
     * // 애니메이션과 함께 이동
     * moveCameraToLocation(mapView,
     *                     latitude: 37.5665,
     *                     longitude: 126.9780, 
     *                     zoom: 15.0,
     *                     animated: true)
     * ```
     *
     * @param mapView 카메라를 이동시킬 지도 뷰
     * @param latitude 목표 위도 (-90.0 ~ 90.0)
     * @param longitude 목표 경도 (-180.0 ~ 180.0)
     * @param zoom 줌 레벨 (0.0 ~ 20.0, 클수록 확대)
     * @param animated 애니메이션 적용 여부 (기본값: false)
     */
    private func moveCameraToLocation(
        _ mapView: NMFMapView,
        latitude: Double,
        longitude: Double,
        zoom: Double,
        animated: Bool = false
    ) {
        let coord = NMGLatLng(lat: latitude, lng: longitude)
        let cameraUpdate = NMFCameraUpdate(scrollTo: coord, zoomTo: zoom)
        
        if animated {
            cameraUpdate.animation = .easeIn
            cameraUpdate.animationDuration = MapConstants.Animation.duration
        }
        
        mapView.moveCamera(cameraUpdate)
    }
    
    /**
     * 카메라 업데이트 통합 처리
     *
     * 상태 변화에 따라 적절한 카메라 이동을 수행하는 중앙 컨트롤러입니다.
     *
     * ## 처리 순서 (우선순위 순)
     * 1. **GPS 포커싱 처리**
     *    - 조건: isLocationFocused == true && userLocation != nil
     *    - 동작: 사용자 위치로 카메라 이동
     *    - 플래그: hasMovedToUserLocation
     *
     * 2. **장소 포커싱 처리**
     *    - 조건: selectedLocation != nil && focusedPlaces에 값 있음
     *    - 동작: 선택된 장소로 카메라 이동
     *    - 플래그: hasMovedToFocusedPlace
     *
     * 3. **초기 영역 설정**
     *    - 조건: isInitialLoad == true && pickList에 값 있음
     *    - 동작: 모든 마커가 보이도록 영역 설정
     *    - 플래그: isInitialLoad
     *
     * ## 플래그 관리
     * - 각 동작은 한 번만 수행 (플래그로 제어)
     * - 상태 변경 시 플래그 리셋
     * - 불필요한 카메라 이동 방지
     *
     * @param mapView 업데이트할 지도 뷰
     * @param coordinator 상태 플래그를 관리하는 코디네이터
     */
    private func handleCameraUpdates(mapView: NMFMapView, coordinator: NMapViewCoordinator) {
        // GPS 포커싱 처리
        if isLocationFocused && userLocation != nil && !coordinator.hasMovedToUserLocation {
            focusOnUserLocation(mapView: mapView, coordinator: coordinator)
        } else if !isLocationFocused {
            coordinator.hasMovedToUserLocation = false
        }
        
        // 장소 포커싱 처리
        if selectedLocation != nil && !focusedPlaces.isEmpty && !coordinator.hasMovedToFocusedPlace {
            focusOnSelectedPlace(mapView: mapView, coordinator: coordinator)
        } else if focusedPlaces.isEmpty {
            coordinator.hasMovedToFocusedPlace = false
        }
        
        // 초기 로드시 전체 픽리스트 영역 표시
        if coordinator.isInitialLoad && !pickList.isEmpty {
            setInitialBounds(mapView: mapView, coordinator: coordinator)
        }
    }
    
    /**
     * 사용자 위치로 카메라 포커싱
     *
     * GPS 버튼이 활성화되었을 때 사용자의 현재 위치로 카메라를 이동시킵니다.
     *
     * ## 수행 작업
     * 1. 사용자 위치 유효성 검사
     * 2. 카메라 이동 (애니메이션 포함)
     * 3. 사용자 위치 마커 업데이트
     * 4. 이동 완료 플래그 설정
     *
     * ## 설정값
     * - 줌 레벨: station (15.0) - 상세 보기
     * - 애니메이션: easeIn (0.5초)
     * - 마커: 파란색 현재 위치 아이콘
     *
     * ## 호출 조건
     * - isLocationFocused == true
     * - userLocation != nil
     * - hasMovedToUserLocation == false
     *
     * @param mapView 카메라를 이동시킬 지도 뷰
     * @param coordinator 상태 플래그 및 마커 관리 코디네이터
     */
    private func focusOnUserLocation(mapView: NMFMapView, coordinator: NMapViewCoordinator) {
        guard let userLocation = userLocation else { return }
        
        moveCameraToLocation(
            mapView,
            latitude: userLocation.coordinate.latitude,
            longitude: userLocation.coordinate.longitude,
            zoom: MapConstants.ZoomLevel.station,
            animated: true
        )
        
        coordinator.updateUserLocationMarker(mapView: mapView, location: userLocation)
        coordinator.hasMovedToUserLocation = true
    }
    
    /**
     * 선택된 장소로 카메라 포커싱
     *
     * 검색이나 마커 선택으로 특정 장소가 선택되었을 때 해당 위치로 카메라를 이동시킵니다.
     *
     * ## 수행 작업
     * 1. 선택된 위치 유효성 검사
     * 2. 카메라 이동 (애니메이션 포함)
     * 3. 포커싱 완료 플래그 설정
     *
     * ## 설정값
     * - 줌 레벨: town (14.0) - 동네 전체 보기
     * - 애니메이션: easeIn (0.5초)
     * - 포커싱 범위: 선택된 장소 주변 지역
     *
     * ## 호출 조건
     * - selectedLocation != nil
     * - focusedPlaces.isEmpty == false
     * - hasMovedToFocusedPlace == false
     *
     * ## 사용 케이스
     * - 검색 결과 선택
     * - 마커 탭
     * - 카드 선택
     * - 딥링크로 전달받은 위치
     *
     * @param mapView 카메라를 이동시킬 지도 뷰
     * @param coordinator 상태 플래그 관리 코디네이터
     */
    private func focusOnSelectedPlace(mapView: NMFMapView, coordinator: NMapViewCoordinator) {
        guard let location = selectedLocation else { return }
        
        moveCameraToLocation(
            mapView,
            latitude: location.latitude,
            longitude: location.longitude,
            zoom: MapConstants.ZoomLevel.town,
            animated: true
        )
        
        coordinator.hasMovedToFocusedPlace = true
    }
    
    /**
     * 초기 영역 설정
     *
     * 지도가 처음 로드될 때 모든 픽리스트 마커가 화면에 표시되도록 카메라 영역을 자동 조정합니다.
     *
     * ## 알고리즘
     * 1. 모든 픽리스트 장소의 좌표 수집
     * 2. 최소/최대 위도/경도 계산
     * 3. NMGLatLngBounds 생성
     * 4. 패딩을 포함하여 카메라 영역 설정
     * 5. 자동으로 적절한 줌 레벨 결정
     *
     * ## 설정값
     * - 패딩: 50 포인트 (모든 방향)
     * - 줌 레벨: 자동 계산 (모든 마커가 보이는 최적 레벨)
     * - 애니메이션: 없음 (즉시 적용)
     *
     * ## 호출 조건
     * - isInitialLoad == true (처음 한 번만)
     * - pickList.isEmpty == false
     *
     * ## 효과
     * - 사용자가 전체 픽리스트를 한눈에 볼 수 있음
     * - 마커가 화면 가장자리에 걸리지 않음
     * - 적절한 줌 레벨로 자동 조정
     *
     * @param mapView 영역을 설정할 지도 뷰
     * @param coordinator 초기 로드 플래그 관리 코디네이터
     */
    private func setInitialBounds(mapView: NMFMapView, coordinator: NMapViewCoordinator) {
        let bounds = NMGLatLngBounds(latLngs: pickList.map {
            NMGLatLng(lat: $0.latitude, lng: $0.longitude)
        })
        
        let cameraUpdate = NMFCameraUpdate(fit: bounds, padding: MapConstants.Layout.boundsPadding)
        mapView.moveCamera(cameraUpdate)
        coordinator.isInitialLoad = false
    }
}
//
//  NMapViewCoordinator+Marker.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/14/25.
//

import Foundation
import NMapsMap
import CoreLocation

/**
 * NMapViewCoordinator+Marker
 *
 * NMapViewCoordinator의 마커 관리 기능을 확장하는 Extension입니다.
 * 픽리스트 기반 마커의 전체 생명주기를 관리합니다.
 *
 * ## 주요 기능
 * 1. **마커 생성**: 새로운 픽리스트 장소에 대한 마커 생성
 * 2. **마커 업데이트**: 기존 마커의 위치, 상태, 캡션 업데이트
 * 3. **마커 삭제**: 픽리스트에서 제외된 마커 제거
 * 4. **마커 상호작용**: 터치 이벤트 처리 및 선택 상태 관리
 *
 * ## 마커 관리 전략
 * - 딕셔너리 기반 관리로 O(1) 검색 성능
 * - 차분 업데이트로 불필요한 재생성 방지
 * - weak self 사용으로 메모리 누수 방지
 *
 * ## 성능 최적화
 * - 마커 재사용: 기존 마커는 업데이트만 수행
 * - 배치 처리: 여러 마커를 한 번에 처리
 * - 디바운싱: 연속 터치 이벤트 제한
 */
extension NMapViewCoordinator {
    
    // MARK: - Public Methods
    
    /**
     * 지도 마커 전체 업데이트
     *
     * 픽리스트 데이터를 기반으로 지도의 모든 마커를 동기화합니다.
     * 새로운 장소는 추가하고, 변경된 장소는 업데이트하며, 제거된 장소는 삭제합니다.
     *
     * ## 알고리즘 (Differential Update)
     * ```
     * 1. 현재 마커 ID 집합 생성
     * 2. 픽리스트 순회:
     *    - 기존 마커 있음 → 업데이트
     *    - 기존 마커 없음 → 생성
     * 3. 남은 ID들 → 삭제
     * ```
     *
     * ## 성능
     * - 시간 복잡도: O(n) where n = max(픽리스트 크기, 현재 마커 수)
     * - 공간 복잡도: O(n) for ID 추적
     *
     * ## 호출 시점
     * - 픽리스트 데이터 변경 시
     * - 선택 상태 변경 시
     * - updateUIView에서 매번 호출 (최적화됨)
     *
     * @param mapView 마커를 표시할 지도 뷰
     * @param pickList 서버에서 받은 픽리스트 장소 목록
     *                 - placeId: 고유 식별자
     *                 - placeName: 표시할 이름
     *                 - latitude/longitude: 좌표
     * @param selectedPlaceId 현재 선택된 장소 ID (nil이면 선택 없음)
     */
    func updateMarkers(mapView: NMFMapView, 
                      pickList: [PickListCardResponse], 
                      selectedPlaceId: Int?) {
        
        // 현재 표시중인 마커 ID 추적 (삭제 대상 찾기용)
        var currentMarkerIds = Set(markers.keys)
        
        // 픽리스트의 각 장소에 대해 마커 처리
        for pickCard in pickList {
            let placeId = pickCard.placeId
            let isSelected = placeId == selectedPlaceId
            
            if let existingMarker = markers[placeId] {
                // 기존 마커가 있으면 업데이트만 수행
                updateExistingMarker(existingMarker, with: pickCard, isSelected: isSelected)
                currentMarkerIds.remove(placeId)  // 삭제 대상에서 제외
            } else {
                // 새로운 마커 생성
                createNewMarker(for: pickCard, isSelected: isSelected, mapView: mapView)
            }
        }
        
        // 픽리스트에 없는 마커들 제거
        removeOutdatedMarkers(with: currentMarkerIds)
    }
    
    // MARK: - Private Methods - Marker Updates
    
    /**
     * 기존 마커 업데이트
     *
     * 이미 존재하는 마커의 속성을 업데이트합니다.
     * 마커를 재생성하지 않고 속성만 변경하여 성능을 최적화합니다.
     *
     * ## 업데이트 항목
     * 1. **위치**: 좌표가 변경된 경우 (장소 정보 수정)
     * 2. **아이콘**: 선택 상태 변경
     * 3. **메타데이터**: placeId, placeName
     * 4. **캡션**: 텍스트 및 표시 설정
     *
     * ## 애니메이션
     * - 위치 변경: 부드러운 이동 (자동)
     * - 아이콘 변경: 즉시 적용
     *
     * @param marker 업데이트할 마커 인스턴스
     * @param pickCard 새로운 장소 정보
     * @param isSelected 선택 상태 여부
     */
    private func updateExistingMarker(_ marker: NMFMarker,
                                      with pickCard: PickListCardResponse,
                                      isSelected: Bool) {
        // 위치 업데이트 (좌표가 변경되었을 수 있음)
        marker.position = NMGLatLng(lat: pickCard.latitude, lng: pickCard.longitude)
        
        // 아이콘 변경 (선택 상태에 따라)
        marker.iconImage = isSelected ? selectedMarkerImage : defaultMarkerImage
        
        // 메타데이터 업데이트 (터치 핸들러에서 사용)
        marker.userInfo = [
            "placeId": pickCard.placeId,
            "placeName": pickCard.placeName
        ]
        
        // 캡션 재설정
        configureMarkerCaption(marker, with: pickCard.placeName, isSelected: isSelected)
    }
    
    /**
     * 새로운 마커 생성
     *
     * 픽리스트에 새로 추가된 장소에 대한 마커를 생성하고 지도에 추가합니다.
     *
     * ## 마커 설정
     * - **크기**: 자동 크기 (NMF_MARKER_SIZE_AUTO)
     * - **앵커**: 하단 중앙 (0.5, 1.0)
     * - **터치**: 활성화 (touchHandler 설정)
     * - **캡션**: 장소명 표시
     *
     * ## 터치 핸들러
     * - weak self 사용으로 순환 참조 방지
     * - 터치 시 해당 장소 선택 및 포커싱
     *
     * ## 메모리 관리
     * - markers 딕셔너리에 강한 참조로 저장
     * - mapView = nil 설정 시 자동 해제
     *
     * @param pickCard 새로 추가할 장소 정보
     * @param isSelected 초기 선택 상태
     * @param mapView 마커를 추가할 지도 뷰
     */
    private func createNewMarker(for pickCard: PickListCardResponse,
                                 isSelected: Bool,
                                 mapView: NMFMapView) {
        let marker = NMFMarker()
        
        // 기본 속성 설정
        marker.position = NMGLatLng(lat: pickCard.latitude, lng: pickCard.longitude)
        marker.width = CGFloat(NMF_MARKER_SIZE_AUTO)
        marker.height = CGFloat(NMF_MARKER_SIZE_AUTO)
        marker.iconImage = isSelected ? selectedMarkerImage : defaultMarkerImage
        
        // 메타데이터 저장 (터치 이벤트에서 사용)
        marker.userInfo = [
            "placeId": pickCard.placeId,
            "placeName": pickCard.placeName
        ]
        
        // 캡션 설정
        configureMarkerCaption(marker, with: pickCard.placeName, isSelected: isSelected)
        
        // 터치 핸들러 설정 (weak self로 순환 참조 방지)
        marker.touchHandler = { [weak self] _ -> Bool in
            self?.handleMarkerTouch(marker: marker) ?? false
        }
        
        // 지도에 추가 및 딕셔너리에 저장
        marker.mapView = mapView
        markers[pickCard.placeId] = marker
    }
    
    /**
     * 더 이상 필요없는 마커 제거
     *
     * 픽리스트에서 제외된 장소의 마커를 지도와 메모리에서 제거합니다.
     *
     * ## 제거 과정
     * 1. 마커를 지도에서 제거 (mapView = nil)
     * 2. 딕셔너리에서 제거
     * 3. ARC에 의해 자동 메모리 해제
     *
     * ## 성능
     * - 시간 복잡도: O(n) where n = 제거할 마커 수
     * - 일반적으로 n은 작음 (1~5개)
     *
     * @param ids 제거할 마커들의 placeId 집합
     */
    private func removeOutdatedMarkers(with ids: Set<Int>) {
        for id in ids {
            if let marker = markers[id] {
                marker.mapView = nil  // 지도에서 제거
                markers.removeValue(forKey: id)  // 딕셔너리에서 제거
            }
        }
    }
    
    // MARK: - Marker Configuration
    
    /**
     * 마커 캡션(라벨) 설정
     *
     * 마커 아래에 표시되는 장소명 텍스트를 설정합니다.
     * 줌 레벨과 선택 상태에 따라 표시 여부가 결정됩니다.
     *
     * ## 캡션 설정값
     * - **텍스트 크기**: 14pt
     * - **최소 줌 레벨**:
     *   - 선택됨: 0 (항상 표시)
     *   - 일반: 10 (확대 시 표시)
     * - **최대 줌 레벨**: 20
     * - **위치**: 마커 하단 중앙
     * - **오프셋**: 4pt
     *
     * ## 표시 규칙
     * 1. 선택된 마커: 줌 레벨과 관계없이 항상 표시
     * 2. 일반 마커: 줌 레벨 10 이상에서만 표시
     * 3. 겹침 처리: SDK가 자동으로 우선순위 결정
     *
     * @param marker 캡션을 설정할 마커
     * @param placeName 표시할 장소명 텍스트
     * @param isSelected 마커 선택 상태
     */
    private func configureMarkerCaption(_ marker: NMFMarker,
                                        with placeName: String,
                                        isSelected: Bool) {
        // 텍스트 설정
        marker.captionText = placeName
        marker.captionTextSize = MapConstants.MarkerCaption.textSize
        
        // 줌 레벨 설정 (선택된 마커는 항상 캡션 표시)
        marker.captionMinZoom = isSelected ? 
            MapConstants.MarkerCaption.selectedMinZoom : 
            MapConstants.MarkerCaption.defaultMinZoom
        marker.captionMaxZoom = MapConstants.MarkerCaption.maxZoom
        
        // 위치 설정
        marker.anchor = CGPoint(x: 0.5, y: 1.0)  // 마커 하단 중앙 기준
        marker.captionOffset = MapConstants.MarkerCaption.offset  // 마커로부터 거리
        marker.captionAligns = [.bottom]  // 마커 아래쪽 정렬
    }
    
    // MARK: - Marker Interaction
    
    /**
     * 마커 터치 이벤트 처리
     *
     * 사용자가 마커를 탭했을 때 호출되어 해당 장소를 선택하고 포커싱합니다.
     *
     * ## 처리 과정
     * 1. **중복 터치 방지**: 처리 중 플래그 확인
     * 2. **장소 ID 추출**: userInfo에서 placeId 가져오기
     * 3. **UI 업데이트**: 모든 마커 리셋 후 선택 마커만 강조
     * 4. **Store 액션**: 
     *    - clearFocusedPlaces: 기존 포커스 해제
     *    - fetchFocusedPlace: 새 장소 포커싱
     * 5. **디바운싱**: 0.5초간 추가 터치 차단
     *
     * ## 스레드 안전성
     * - UI 업데이트는 Main Queue에서 수행
     * - weak self로 순환 참조 방지
     *
     * ## 반환값
     * - true: 이벤트 처리 완료 (SDK가 추가 처리 안 함)
     * - false: 이벤트 무시 (거의 발생 안 함)
     *
     * @param marker 터치된 마커 인스턴스
     * @return 이벤트 처리 여부 (항상 true)
     */
    private func handleMarkerTouch(marker: NMFMarker) -> Bool {
        // 이미 처리 중이면 무시 (중복 터치 방지)
        guard !isProcessingMarkerTouch else { return true }
        
        // 장소 ID 추출
        guard let placeId = marker.userInfo["placeId"] as? Int else { return false }
        
        // 처리 시작 플래그 설정
        isProcessingMarkerTouch = true
        
        // Main Queue에서 UI 업데이트
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 모든 마커를 기본 상태로 리셋
            self.resetAllMarkers()
            
            // 터치된 마커만 선택 상태로 변경
            marker.iconImage = self.selectedMarkerImage
            
            // Store에 액션 전송
            self.store.send(.clearFocusedPlaces)  // 기존 포커스 클리어
            self.store.send(.fetchFocusedPlace(placeId: placeId))  // 새로운 장소 포커스
            
            // 0.5초 후 플래그 리셋 (연속 터치 방지)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isProcessingMarkerTouch = false
            }
        }
        
        return true
    }
    
    /**
     * 모든 마커를 기본 상태로 리셋
     *
     * 선택된 마커를 해제하고 모든 마커를 일반 상태로 되돌립니다.
     *
     * ## 리셋 항목
     * 1. **아이콘**: 기본 마커 이미지로 변경
     * 2. **캡션**: 일반 상태 설정 (줌 레벨 10 이상에서만 표시)
     *
     * ## 사용 시점
     * - 지도 탭으로 선택 해제
     * - 새로운 마커 선택 전
     * - 포커스 클리어
     *
     * ## 성능
     * - 시간 복잡도: O(n) where n = 전체 마커 수
     * - 일반적으로 n < 100
     */
    func resetAllMarkers() {
        for (_, marker) in markers {
            // 아이콘을 기본 상태로
            marker.iconImage = defaultMarkerImage
            
            // 캡션도 기본 상태로 리셋
            if let placeName = marker.userInfo["placeName"] as? String {
                configureMarkerCaption(marker, with: placeName, isSelected: false)
            }
        }
    }
}

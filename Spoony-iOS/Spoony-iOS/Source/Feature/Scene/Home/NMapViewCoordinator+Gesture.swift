//
//  NMapViewCoordinator+Gesture.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/14/25.
//

import UIKit
import NMapsMap

/**
 * NMapViewCoordinator+Gesture
 *
 * NMapViewCoordinator의 제스처 및 터치 이벤트 처리 기능을 확장하는 Extension입니다.
 * 사용자의 지도 인터랙션을 감지하고 적절한 액션으로 변환합니다.
 *
 * ## 주요 기능
 * 1. **지도 탭 처리**: 빈 공간 탭으로 선택 해제
 * 2. **제스처 필터링**: 마커 영역과 지도 영역 구분
 * 3. **제스처 충돌 방지**: 네이티브 제스처와 커스텀 제스처 조화
 * 4. **터치 델리게이트**: 네이버 지도 SDK 터치 이벤트 처리
 *
 * ## 제스처 우선순위
 * 1. 마커 터치 핸들러 (최우선)
 * 2. 지도 컨트롤 (줌, 나침반 등)
 * 3. 커스텀 탭 제스처
 * 4. 지도 기본 제스처 (팬, 핀치 등)
 *
 * ## 스레드 안전성
 * - UI 업데이트는 Main Queue에서 수행
 * - weak self로 순환 참조 방지
 */
extension NMapViewCoordinator: UIGestureRecognizerDelegate {
    
    // MARK: - Map Tap Handling
    
    /**
     * 지도 탭 제스처 처리
     *
     * 사용자가 마커가 아닌 빈 지도 영역을 탭했을 때 호출됩니다.
     * 현재 선택된 마커를 해제하고 포커스를 클리어합니다.
     *
     * ## 처리 과정
     * 1. **선택 상태 확인**: selectedPlace가 nil이면 무시
     * 2. **마커 리셋**: 모든 마커를 기본 상태로 변경
     * 3. **Store 액션**:
     *    - selectPlace(nil): 선택 해제
     *    - clearFocusedPlaces: 포커스 클리어
     *
     * ## 사용 시나리오
     * - 사용자가 선택을 취소하고 싶을 때
     * - 다른 UI로 포커스를 이동하고 싶을 때
     * - 전체 지도를 다시 보고 싶을 때
     *
     * ## @objc 속성
     * - UITapGestureRecognizer의 타겟 메서드로 사용
     * - Objective-C 런타임에서 호출 가능해야 함
     *
     * @param gesture 탭 제스처 인식기
     *                - 위치 정보 포함
     *                - 상태 정보 포함
     */
    @objc func handleMapTap(_ gesture: UITapGestureRecognizer) {
        // 선택된 장소가 없으면 아무 동작도 하지 않음
        guard selectedPlace != nil else { return }
        
        // Main Queue에서 UI 및 상태 업데이트
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 모든 마커를 기본 상태로 리셋
            self.resetAllMarkers()
            
            // Store에 선택 해제 액션 전송
            self.store.send(.selectPlace(nil))          // 선택 해제
            self.store.send(.clearFocusedPlaces)        // 포커스 클리어
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    /**
     * 제스처 터치 수신 여부 결정
     *
     * 터치 이벤트가 발생했을 때 해당 제스처가 이를 처리할지 결정합니다.
     * 마커나 지도 컨트롤 영역은 제외하고 빈 지도 영역만 처리합니다.
     *
     * ## 판단 로직
     * 1. **터치 위치 확인**: 화면상 터치 좌표 획득
     * 2. **히트 테스트**: 해당 위치의 최상위 뷰 확인
     * 3. **클래스명 검사**: 
     *    - "Marker" 포함: 마커 영역 (false 반환)
     *    - "NMF" 포함: 네이버 지도 컨트롤 (false 반환)
     *    - 그 외: 일반 지도 영역 (true 반환)
     *
     * ## 중요성
     * - 마커 터치와 지도 탭을 구분하는 핵심 로직
     * - 잘못 구현하면 마커 선택이 안 되거나 중복 처리됨
     *
     * ## 성능
     * - 히트 테스트는 뷰 계층 탐색 (O(depth))
     * - 클래스명 문자열 검사 (O(1))
     *
     * @param gestureRecognizer 제스처 인식기
     * @param touch 터치 이벤트 객체
     *              - 위치 정보
     *              - 타임스탬프
     *              - 터치 타입
     * @return true: 제스처가 터치 처리
     *         false: 다른 핸들러에게 전달
     */
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        
        // 터치 포인트 획득
        let touchPoint = touch.location(in: gestureRecognizer.view)
        
        // 터치 포인트에서 히트 테스트 수행
        if let view = gestureRecognizer.view?.hitTest(touchPoint, with: nil) {
            // 뷰의 클래스명 확인
            let className = NSStringFromClass(type(of: view))
            
            // 마커나 네이버 지도 컨트롤 영역이면 제스처 무시
            // (각자의 터치 핸들러가 처리하도록 위임)
            if className.contains("Marker") || className.contains("NMF") {
                return false  // 이 제스처는 처리하지 않음
            }
        }
        
        return true  // 빈 지도 영역이므로 처리
    }
    
    /**
     * 동시 제스처 인식 허용 설정
     *
     * 여러 제스처 인식기가 동시에 작동할 수 있는지 결정합니다.
     * 지도의 기본 제스처(팬, 줌)와 커스텀 탭 제스처가 충돌하지 않도록 합니다.
     *
     * ## 동작 방식
     * - true 반환: 두 제스처가 동시에 인식 가능
     * - false 반환: 하나의 제스처만 인식 (기본값)
     *
     * ## 사용 케이스
     * 1. **탭 + 팬**: 탭하면서 동시에 지도 이동 가능
     * 2. **탭 + 줌**: 탭하면서 동시에 확대/축소 가능
     *
     * ## 주의사항
     * - 너무 많은 제스처를 동시 허용하면 의도치 않은 동작 발생
     * - 사용자 경험을 고려하여 적절히 제한 필요
     *
     * @param gestureRecognizer 첫 번째 제스처 인식기 (우리의 탭 제스처)
     * @param otherGestureRecognizer 두 번째 제스처 인식기 (지도 기본 제스처)
     * @return true: 동시 인식 허용
     *         false: 동시 인식 차단
     */
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // 지도의 팬, 줌 제스처와 탭 제스처가 충돌하지 않도록 허용
        return true
    }
}

// MARK: - NMFMapViewTouchDelegate

/**
 * 네이버 지도 터치 델리게이트 구현
 *
 * 네이버 지도 SDK에서 제공하는 터치 이벤트 델리게이트를 구현합니다.
 * 지도 탭, 심볼 탭, 오버레이 탭 등의 이벤트를 처리할 수 있습니다.
 *
 * ## 델리게이트 메서드
 * - mapView(_:didTapMap:): 지도 탭
 * - mapView(_:didTap:): 심볼 탭
 * - mapView(_:didTapOverlay:): 오버레이 탭
 *
 * ## 이벤트 처리 순서
 * 1. 오버레이 (마커 등)
 * 2. 심볼 (POI, 건물 등)
 * 3. 지도 빈 공간
 */
extension NMapViewCoordinator: NMFMapViewTouchDelegate {
    
    /**
     * 지도 탭 이벤트 처리
     *
     * 사용자가 지도의 빈 공간을 탭했을 때 호출됩니다.
     * 마커나 심볼이 없는 영역을 탭한 경우에만 호출됩니다.
     *
     * ## 현재 구현
     * - false 반환: 기본 동작 유지
     * - UITapGestureRecognizer가 대신 처리
     *
     * ## 활용 가능성
     * - 탭한 위치에 새 마커 추가
     * - 좌표 정보 표시
     * - 역지오코딩으로 주소 확인
     *
     * ## 반환값 의미
     * - true: 이벤트 소비 (SDK가 추가 처리 안 함)
     * - false: 이벤트 전파 (다른 핸들러 처리 가능)
     *
     * @param mapView 이벤트가 발생한 지도 뷰
     * @param latlng 탭한 위치의 위도/경도 좌표
     *               - lat: 위도 (-90 ~ 90)
     *               - lng: 경도 (-180 ~ 180)
     * @return false: 다른 제스처 인식기가 처리하도록 전달
     */
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng) -> Bool {
        // 기본 동작 유지 (UITapGestureRecognizer가 처리)
        // 필요시 여기서 좌표 기반 추가 동작 구현 가능
        return false
    }
    
    /**
     * 지도 심볼 탭 이벤트 처리
     *
     * POI(관심 지점), 건물, 대중교통 정류장 등의 심볼을 탭했을 때 호출됩니다.
     * 네이버 지도가 기본 제공하는 심볼들에 대한 이벤트입니다.
     *
     * ## 심볼 종류
     * - POI: 음식점, 카페, 편의점 등
     * - 건물: 주요 건물명
     * - 대중교통: 지하철역, 버스정류장
     * - 기타: 공원, 학교 등
     *
     * ## 활용 예시
     * - 심볼 정보 팝업 표시
     * - 해당 장소 상세 정보 로드
     * - 길찾기 시작점/도착점 설정
     *
     * ## 현재 구현
     * - false 반환: 네이버 지도 기본 동작 유지
     * - 기본 동작: 심볼명 표시, 정보 팝업 등
     *
     * @param mapView 이벤트가 발생한 지도 뷰
     * @param symbol 탭한 심볼 객체
     *               - caption: 심볼 이름
     *               - position: 위치 좌표
     *               - iconImage: 아이콘 이미지
     * @return false: 네이버 지도 기본 동작 수행
     */
    func mapView(_ mapView: NMFMapView, didTap symbol: NMFSymbol) -> Bool {
        // 심볼 탭은 기본 동작 유지
        // 네이버 지도가 자체적으로 심볼 정보를 표시
        return false
    }
}

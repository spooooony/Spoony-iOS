//
//  MapConstants.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/14/25.
//

import Foundation
import NMapsMap

/**
 * MapConstants
 *
 * 네이버 지도 관련 모든 상수값을 중앙화하여 관리하는 네임스페이스입니다.
 * 
 * ## 주요 역할
 * - 지도 줌 레벨 상수 정의
 * - 기본 위치 좌표 관리
 * - 마커 이미지 리소스 관리
 * - 애니메이션 설정값 정의
 * - UI 레이아웃 수치 관리
 * - 마커 캡션 설정값 정의
 *
 * ## 사용 예시
 * ```swift
 * let zoomLevel = MapConstants.ZoomLevel.district
 * let markerImage = MapConstants.MarkerImage.selectedMarker
 * ```
 *
 * ## 주의사항
 * - 모든 상수는 static으로 선언되어 인스턴스 생성 없이 사용
 * - 앱 전역에서 일관된 값을 사용하기 위해 이 파일에서만 관리
 */
enum MapConstants {
    
    /**
     * ZoomLevel
     *
     * 지도의 줌 레벨을 정의하는 상수 그룹입니다.
     * 네이버 지도의 줌 레벨은 0~20까지 지원되며, 숫자가 클수록 더 확대됩니다.
     *
     * ## 줌 레벨 가이드
     * - 0~5: 국가/대륙 수준
     * - 6~10: 도시 수준  
     * - 11~14: 구/동 수준
     * - 15~20: 건물/거리 수준
     */
    enum ZoomLevel {
        /**
         * 구(district) 수준의 줌 레벨
         *
         * - 값: 11.5
         * - 용도: 서울의 한 구 전체가 화면에 표시되는 수준
         * - 사용처: 초기 지도 로드 시, 위치 권한이 없을 때의 기본 표시
         * - 예시: 강남구 전체가 보이는 정도의 축척
         */
        static let district: Double = 11.5
        
        /**
         * 동(town) 수준의 줌 레벨
         *
         * - 값: 14.0
         * - 용도: 특정 동네나 상권이 화면에 표시되는 수준
         * - 사용처: 장소 검색 결과 표시, 특정 지역 포커싱
         * - 예시: 역삼동, 논현동 정도의 범위가 보이는 축척
         */
        static let town: Double = 14.0
        
        /**
         * 역(station) 수준의 줌 레벨
         *
         * - 값: 15.0
         * - 용도: 지하철역 주변이나 특정 블록이 상세히 보이는 수준
         * - 사용처: 사용자 현재 위치 표시, 마커 선택 시 포커싱
         * - 예시: 강남역 주변 500m 반경이 보이는 정도의 축척
         */
        static let station: Double = 15.0
    }
    
    /**
     * DefaultLocation
     *
     * 사용자 위치를 가져올 수 없을 때 사용하는 기본 좌표입니다.
     * 
     * ## 사용 시나리오
     * - 위치 권한이 거부된 경우
     * - 위치 서비스가 비활성화된 경우
     * - 네트워크 오류로 위치를 가져올 수 없는 경우
     * - 앱 최초 실행 시 위치 권한 요청 전
     */
    enum DefaultLocation {
        /**
         * 기본 위도 좌표
         *
         * - 값: 37.5563 (서울 중심부)
         * - 설명: 서울특별시청 인근의 위도
         * - 선정 이유: 서울의 지리적 중심이며 접근성이 좋은 위치
         */
        static let latitude: Double = 37.5563
        
        /**
         * 기본 경도 좌표
         *
         * - 값: 126.9236 (서울 중심부)
         * - 설명: 서울특별시청 인근의 경도
         * - 선정 이유: 주요 교통 중심지와 가까운 위치
         */
        static let longitude: Double = 126.9236
    }
    
    /**
     * MarkerImage
     *
     * 지도에서 사용하는 마커 이미지 리소스를 관리합니다.
     * Assets 카탈로그에 정의된 이미지와 매핑됩니다.
     *
     * ## 이미지 요구사항
     * - 형식: PNG (투명 배경 권장)
     * - 크기: @1x: 30x40, @2x: 60x80, @3x: 90x120
     * - 앵커포인트: 이미지 하단 중앙
     */
    enum MarkerImage {
        /**
         * 기본 마커 이미지
         *
         * - Asset 이름: "ic_unselected_marker"
         * - 용도: 선택되지 않은 일반 장소 표시
         * - 디자인: 회색 또는 연한 색상의 핀 아이콘
         * - 상태: 비활성 상태를 나타냄
         */
        static let defaultMarker = NMFOverlayImage(name: "ic_unselected_marker")
        
        /**
         * 선택된 마커 이미지
         *
         * - Asset 이름: "ic_selected_marker"
         * - 용도: 사용자가 선택한 장소 강조 표시
         * - 디자인: 주 색상(Primary Color)의 핀 아이콘
         * - 상태: 활성/선택 상태를 나타냄
         * - 특징: 기본 마커보다 시각적으로 두드러짐
         */
        static let selectedMarker = NMFOverlayImage(name: "ic_selected_marker")
        
        /**
         * 사용자 위치 마커 이미지
         *
         * - Asset 이름: "ic_my_location"
         * - 용도: 사용자의 현재 위치 표시
         * - 디자인: 파란색 점 또는 화살표 아이콘
         * - 특징: 다른 마커와 구별되는 독특한 디자인
         * - 업데이트: GPS 신호에 따라 실시간으로 위치 갱신
         */
        static let userLocation = NMFOverlayImage(name: "ic_my_location")
    }
    
    /**
     * Animation
     *
     * 지도 카메라 이동 시 사용하는 애니메이션 설정값입니다.
     *
     * ## 애니메이션 타입
     * - easeIn: 천천히 시작해서 빠르게 끝남
     * - easeOut: 빠르게 시작해서 천천히 끝남
     * - linear: 일정한 속도로 진행
     */
    enum Animation {
        /**
         * 기본 애니메이션 지속 시간
         *
         * - 값: 0.5초
         * - 용도: 일반적인 카메라 이동
         * - 사용처:
         *   - GPS 버튼 탭 시 사용자 위치로 이동
         *   - 초기 로드 시 지도 위치 설정
         *   - 검색 결과로 이동
         * - UX 고려사항: 너무 빠르면 어지럽고, 너무 느리면 답답함
         */
        static let duration: TimeInterval = 0.5
        
        /**
         * 짧은 애니메이션 지속 시간
         *
         * - 값: 0.2초
         * - 용도: 빠른 전환이 필요한 경우
         * - 사용처:
         *   - 마커 선택 시 포커싱
         *   - 근거리 이동
         *   - 줌 레벨만 변경
         * - UX 고려사항: 즉각적인 반응이 필요한 인터랙션
         */
        static let shortDuration: TimeInterval = 0.2
    }
    
    /**
     * Layout
     *
     * UI 레이아웃과 관련된 수치를 정의합니다.
     * 디바이스 크기에 따라 조정이 필요할 수 있습니다.
     *
     * ## 반응형 처리
     * - adjustedH, adjustedW 등의 extension 메서드와 함께 사용
     * - 디바이스별 스케일 팩터 적용
     */
    enum Layout {
        /**
         * 칩 영역 높이
         *
         * - 값: 100 (조정 전 기준값)
         * - 용도: 상단 필터 칩들이 차지하는 영역 높이
         * - 사용처: 네이버 지도 로고 위치 조정
         * - 계산: 실제 사용 시 adjustedH로 디바이스별 조정
         * - 주의: 칩 개수가 늘어나면 이 값도 조정 필요
         */
        static let chipAreaHeight: CGFloat = 100
        
        /**
         * 지도 영역 패딩
         *
         * - 값: 50 포인트
         * - 용도: 모든 마커가 보이도록 영역 설정 시 여백
         * - 사용처: 초기 로드 시 bounds fitting
         * - 효과: 마커가 화면 가장자리에 걸리지 않도록 함
         * - 조정: 마커 크기나 캡션 크기에 따라 조정 가능
         */
        static let boundsPadding: CGFloat = 50
        
        /**
         * 로고 오른쪽 여백
         *
         * - 값: 20 포인트
         * - 용도: 네이버 지도 로고의 우측 여백
         * - 위치: 화면 우측 상단
         * - 주의: 네이버 지도 약관상 로고는 반드시 표시되어야 함
         */
        static let logoRightMargin: CGFloat = 20
    }
    
    /**
     * MarkerCaption
     *
     * 마커 아래 표시되는 텍스트 라벨(캡션) 설정값입니다.
     *
     * ## 캡션 표시 규칙
     * - 줌 레벨에 따라 자동으로 표시/숨김
     * - 마커가 겹칠 경우 우선순위에 따라 표시
     * - 선택된 마커의 캡션은 항상 표시
     */
    enum MarkerCaption {
        /**
         * 캡션 텍스트 크기
         *
         * - 값: 14 포인트
         * - 폰트: 시스템 기본 폰트
         * - 색상: 검정색 (변경 가능)
         * - 가독성: 12pt 이하는 읽기 어려움, 16pt 이상은 공간 차지
         */
        static let textSize: CGFloat = 14
        
        /**
         * 선택된 마커의 캡션 최소 표시 줌 레벨
         *
         * - 값: 0 (항상 표시)
         * - 의미: 줌 레벨과 관계없이 항상 캡션 표시
         * - 이유: 선택된 장소는 사용자가 관심있는 곳이므로 항상 보여줌
         * - 효과: 지도를 축소해도 선택된 장소명은 계속 보임
         */
        static let selectedMinZoom: Double = 0
        
        /**
         * 일반 마커의 캡션 최소 표시 줌 레벨
         *
         * - 값: 10
         * - 의미: 줌 레벨 10 이상일 때만 캡션 표시
         * - 이유: 너무 많은 캡션이 겹쳐서 지저분해지는 것 방지
         * - 효과: 지도를 확대할수록 더 많은 장소명이 보임
         */
        static let defaultMinZoom: Double = 10
        
        /**
         * 캡션 최대 표시 줌 레벨
         *
         * - 값: 20 (최대 줌)
         * - 의미: 최대로 확대해도 캡션 표시
         * - 용도: 캡션이 사라지는 상한선 설정
         * - 일반적으로 최대값으로 설정하여 항상 표시
         */
        static let maxZoom: Double = 20
        
        /**
         * 마커와 캡션 사이 거리
         *
         * - 값: 4 포인트
         * - 용도: 마커 아이콘과 텍스트 사이 간격
         * - 위치: 마커 하단으로부터의 거리
         * - 조정: 마커 이미지 크기에 따라 조정 필요
         * - 시각적 효과: 너무 가까우면 겹쳐 보이고, 너무 멀면 연결성 떨어짐
         */
        static let offset: CGFloat = 4
    }
}
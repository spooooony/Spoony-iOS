//
//  SearchService.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/21/25.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

protocol SearchServiceType {
    func searchLocation(query: String) async throws -> SearchListResponse
    func fetchLocationList(locationId: Int) async throws -> ResturantpickListResponse
}

final class SearchService: SearchServiceType {
    private let client: Client
    
    init(baseURL: URL = URL(string: Config.baseURL)!) {
        // URLSession 기반 전송 계층 생성
        let transport = URLSessionTransport()
        
        // OpenAPI 클라이언트 초기화
        self.client = Client(
            serverURL: baseURL,
            transport: transport
        )
    }
    
    func searchLocation(query: String) async throws -> SearchListResponse {
        // searchLocations 작업을 위한 입력 생성
        let input = Operations.searchLocations.Input(
            query: .init(query: query),
            headers: .init()
        )
        
        // 생성된 API 작업 호출
        let response = try await client.searchLocations(input)
        
        // 응답 처리
        switch response {
        case .ok(let okResponse):
            // 응답 본문을 통째로 Data 객체로 변환
            let responseData = try await okResponse.body.any.collect()
            
            // JSON 디코더 생성 및 BaseResponse로 디코딩
            let decoder = JSONDecoder()
            let baseResponse = try decoder.decode(BaseResponse<SearchListResponse>.self, from: responseData)
            
            // BaseResponse 처리 로직
            if baseResponse.success, let data = baseResponse.data {
                return data
            } else if let error = baseResponse.error {
                throw SearchError.serverError(message: "\(error)")
            } else {
                throw SearchError.unknownError
            }
            
        default:
            throw SearchError.networkError
        }
    }
    
    func fetchLocationList(locationId: Int) async throws -> ResturantpickListResponse {
        // getZzimLocationCardList 작업을 위한 입력 생성
        // locationId는 API가 Int64를 요구하므로 변환
        let input = Operations.getZzimLocationCardList.Input(
            path: .init(locationId: Int64(locationId)),
            headers: .init()
        )
        
        // 생성된 API 작업 호출
        let response = try await client.getZzimLocationCardList(input)
        
        // 응답 처리
        switch response {
        case .ok(let okResponse):
            // 응답 본문을 통째로 Data 객체로 변환
            let responseData = try await okResponse.body.any.collect()
            
            // JSON 디코더 생성 및 BaseResponse로 디코딩
            let decoder = JSONDecoder()
            let baseResponse = try decoder.decode(BaseResponse<ResturantpickListResponse>.self, from: responseData)
            
            // BaseResponse 처리 로직
            if baseResponse.success, let data = baseResponse.data {
                return data
            } else {
                throw NSError(domain: "HomeService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data available"])
            }
            
        default:
            throw SearchError.networkError
        }
    }
}

// HTTPBody의 확장 메서드 추가 - 비동기 스트림에서 모든 데이터를 수집
extension HTTPBody {
    func collect() async throws -> Data {
        var data = Data()
        for try await bytes in self {
            data.append(contentsOf: bytes)
        }
        return data
    }
}

// 테스트용 모의 서비스 구현
final class MockSearchService: SearchServiceType {
    func searchLocation(query: String) async throws -> SearchListResponse {
        // 지역 검색 결과 모의 데이터 반환
        return SearchListResponse(locationResponseList: [
            SearchResponse(
                locationId: 1,
                locationName: "서울시 강남구",
                locationAddress: "서울특별시 강남구",
                locationType: SearchLocationType(
                    locationTypeId: 1,
                    locationTypeName: "지역",
                    scope: 5.0
                ),
                longitude: 127.028,
                latitude: 37.495
            )
        ])
    }
    
    func fetchLocationList(locationId: Int) async throws -> ResturantpickListResponse {
        // 북마크된 장소 목록 모의 데이터 반환
        return ResturantpickListResponse(zzimCardResponses: [
            PickListCardResponse(
                placeId: 1,
                placeName: "맛있는 식당",
                placeAddress: "서울시 강남구 테헤란로",
                postTitle: "정말 맛있어요",
                photoUrl: "https://example.com/image.jpg",
                latitude: 127.028,
                longitude: 37.495,
                categoryColorResponse: BottomSheetCategoryColorResponse(
                    categoryId: 1,
                    categoryName: "한식",
                    iconUrl: "icon_url",
                    iconTextColor: "#FFFFFF",
                    iconBackgroundColor: "#FF0000"
                )
            )
        ])
    }
}

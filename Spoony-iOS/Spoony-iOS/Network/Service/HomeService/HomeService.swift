//
//  HomeService.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/21/25.
//

import Foundation
import Moya

protocol HomeServiceType {
    func fetchPickList(userId: Int) async throws -> ResturantpickListResponse
}

final class DefaultHomeService: HomeServiceType {
    func fetchPickList(userId: Int) async throws -> ResturantpickListResponse {
        return try await withCheckedThrowingContinuation { continuation in
            Providers.homeProvider.request(.getMapList(userId: userId)) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<ResturantpickListResponse>.self)
                        guard let data = responseDto.data else {
                            throw NSError(domain: "HomeService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data available"])
                        }
                        continuation.resume(returning: data)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

//final class MockHomeService: HomeServiceType {
//    func fetchPickList(userId: Int) async throws -> ResturantpickListResponse {
//        return ResturantpickListResponse(zzimCardResponses: [
//            .init(
//                placeId: 7,
//                placeName: "스타벅스 강남R점",
//                placeAddress: "서울특별시 강남구 역삼동 825",
//                postTitle: "스타벅스 강남R점 후기",
//                latitude: 37.497711,
//                longitude: 127.028439,
//                categoryColorResponse: .init(
//                    categoryName: "카페",
//                    iconUrl: "url_color_8",
//                    iconTextColor: "url_text_8",
//                    iconBackgroundColor: "background_color_8"
//                )
//            )
//        ])
//    }
    
    func fetchSpoonCount(userId: Int) async throws -> Int {
        return try await withCheckedThrowingContinuation { continuation in
            Providers.homeProvider.request(.getSpoonCount(userId: userId)) { result in
                switch result {
                case let .success(response):
                    do {
                        let baseResponse = try response.map(BaseResponse<SpoonResponse>.self)
                        if baseResponse.success, let data = baseResponse.data {
                            continuation.resume(returning: data.spoonAmount)
                        } else {
                            continuation.resume(throwing: APIError.responseError)
                        }
                    } catch {
                        continuation.resume(throwing: APIError.decodingError)
                    }
                case .failure:
                    continuation.resume(throwing: APIError.invalidResponse)
                }
            }
        }
    }
}

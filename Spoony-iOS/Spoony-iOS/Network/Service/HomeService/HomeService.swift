//
//  HomeService.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/21/25.
//

import Foundation
import NetworkingMacros
import Moya

protocol HomeServiceType {
    func fetchPickList() async throws -> ResturantpickListResponse
    func fetchSpoonCount() async throws -> Int
    func fetchFocusedPlace(placeId: Int) async throws -> MapFocusResponse
    func fetchLocationList(locationId: Int) async throws -> ResturantpickListResponse
    func drawDailySpoon() async throws -> SpoonDrawResponse
}

@NetworkService
final class DefaultHomeService: HomeServiceType {
    
    @NetworkRequest<ResturantpickListResponse>(target: "getMapList")
    func fetchPickList() async throws -> ResturantpickListResponse {}
    
    func fetchSpoonCount() async throws -> Int {
        let response: SpoonCountResponse = try await performRequest(.getSpoonCount, responseType: SpoonCountResponse.self)
        return response.spoonAmount
    }

    func fetchFocusedPlace(placeId: Int) async throws -> MapFocusResponse {
        return try await performRequest(.getMapFocus(placeId: placeId), responseType: MapFocusResponse.self)
    }
    
    func fetchLocationList(locationId: Int) async throws -> ResturantpickListResponse {
        return try await performRequest(.getLocationList(locationId: locationId), responseType: ResturantpickListResponse.self)
    }
    
    func drawDailySpoon() async throws -> SpoonDrawResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.drawSpoon) { result in
                switch result {
                case .success(let response):
                    do {
                        let baseResponse = try response.map(BaseResponse<SpoonDrawResponse>.self)
                        if baseResponse.success, let data = baseResponse.data {
                            continuation.resume(returning: data)
                        } else if let error = baseResponse.error as? [String: String], let message = error["message"] {
                            continuation.resume(throwing: NSError(
                                domain: "SpoonService",
                                code: response.statusCode,
                                userInfo: [NSLocalizedDescriptionKey: message]
                            ))
                        } else {
                            continuation.resume(throwing: SNError.noData)
                        }
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

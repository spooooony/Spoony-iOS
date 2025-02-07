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
    func fetchSpoonCount(userId: Int) async throws -> Int
    func fetchFocusedPlace(userId: Int, placeId: Int) async throws -> MapFocusResponse
    func fetchLocationList(userId: Int, locationId: Int) async throws -> ResturantpickListResponse
}

final class DefaultHomeService: HomeServiceType {
    private let provider = Providers.homeProvider

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

    func fetchFocusedPlace(userId: Int, placeId: Int) async throws -> MapFocusResponse {
            return try await withCheckedThrowingContinuation { continuation in
                provider.request(.getMapFocus(userId: userId, placeId: placeId)) { result in
                    switch result {
                    case let .success(response):
                        do {
                            let baseResponse = try response.map(BaseResponse<MapFocusResponse>.self)
                            if baseResponse.success, let data = baseResponse.data {
                                continuation.resume(returning: data)
                            } else if let error = baseResponse.error {
                                continuation.resume(throwing: SearchError.serverError(message: "\(error)"))
                            } else {
                                continuation.resume(throwing: SearchError.unknownError)
                            }
                        } catch {
                            continuation.resume(throwing: SearchError.decodingError)
                        }
                    case .failure:
                        continuation.resume(throwing: SearchError.networkError)
                    }
                }
            }
        }
    
    func fetchLocationList(userId: Int, locationId: Int) async throws -> ResturantpickListResponse {
            return try await withCheckedThrowingContinuation { continuation in
                provider.request(.getLocationList(userId: userId, locationId: locationId)) { result in
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

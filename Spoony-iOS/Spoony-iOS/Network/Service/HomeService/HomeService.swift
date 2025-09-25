//
//  HomeService.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/21/25.
//

import Foundation
import Moya

protocol HomeServiceType {
    func fetchPickList() async throws -> ResturantpickListResponse
    func fetchSpoonCount() async throws -> Int
    func fetchFocusedPlace(placeId: Int) async throws -> MapFocusResponse
    func fetchLocationList(locationId: Int) async throws -> ResturantpickListResponse
    func drawDailySpoon() async throws -> SpoonDrawResponse
}

final class DefaultHomeService: HomeServiceType {
    let provider = Providers.homeProvider

    func fetchPickList() async throws -> ResturantpickListResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.getMapList) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<ResturantpickListResponse>.self)
                        guard let data = responseDto.data
                        else { throw SNError.decodeError }
                        
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
    
    func fetchSpoonCount() async throws -> Int {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.getSpoonCount) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<SpoonCountResponse>.self)
                        guard let data = responseDto.data
                        else { throw SNError.decodeError }
                        
                        continuation.resume(returning: data.spoonAmount)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func fetchFocusedPlace(placeId: Int) async throws -> MapFocusResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.getMapFocus(placeId: placeId)) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<MapFocusResponse>.self)
                        guard let data = responseDto.data
                        else { throw SNError.decodeError }
                        
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
    
    func fetchLocationList(locationId: Int) async throws -> ResturantpickListResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.getLocationList(locationId: locationId)) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<ResturantpickListResponse>.self)
                        guard let data = responseDto.data
                        else { throw SNError.decodeError }
                        
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
    
    func drawDailySpoon() async throws -> SpoonDrawResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.drawSpoon) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<SpoonDrawResponse>.self)
                        guard let data = responseDto.data
                        else { throw SNError.decodeError }
                        
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

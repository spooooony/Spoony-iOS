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
        do {
            let result = try await provider.request(.getMapList)
                .map(to: BaseResponse<ResturantpickListResponse>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            return data
        } catch {
            throw error
        }
    }
    
    func fetchSpoonCount() async throws -> Int {
        do {
            let result = try await provider.request(.getSpoonCount)
                .map(to: BaseResponse<SpoonCountResponse>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            return data.spoonAmount
        } catch {
            throw error
        }
    }

    func fetchFocusedPlace(placeId: Int) async throws -> MapFocusResponse {
        do {
            let result = try await provider.request(.getMapFocus(placeId: placeId))
                .map(to: BaseResponse<MapFocusResponse>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            return data
        } catch {
            throw error
        }
    }
    
    func fetchLocationList(locationId: Int) async throws -> ResturantpickListResponse {
        do {
            let result = try await provider.request(.getLocationList(locationId: locationId))
                .map(to: BaseResponse<ResturantpickListResponse>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            return data
        } catch {
            throw error
        }
    }
    
    func drawDailySpoon() async throws -> SpoonDrawResponse {
        do {
            let result = try await provider.request(.drawSpoon)
                .map(to: BaseResponse<SpoonDrawResponse>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            return data
        } catch {
            throw error
        }
    }
}

//
//  HomeService.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/21/25.
//

import Foundation
import Moya

protocol RestaurantServiceType {
  //  func fetchPickList(userId: Int) async throws -> ResturantpickListResponse
    func fetchSpoonCount(userId: Int) async throws -> Int
}

final class RestaurantService: RestaurantServiceType {
//    func fetchPickList(userId: Int) async throws -> ResturantpickListResponse {
//        //print("")
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

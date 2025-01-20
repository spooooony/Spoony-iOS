//
//  HomeService.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/21/25.
//

import Foundation

protocol RestaurantServiceType {
    func fetchPickList(userId: Int) async throws -> ResturantpickListResponse
}

final class RestaurantService: RestaurantServiceType {
    func fetchPickList(userId: Int) async throws -> ResturantpickListResponse {
        return try await withCheckedThrowingContinuation { continuation in
            Providers.homeProvider.request(.getMapList(userId: userId)) { result in
                switch result {
                case let .success(response):
                    do {
                        let baseResponse = try response.map(BaseResponse<ResturantpickListResponse>.self)
                        if baseResponse.success == 1, let data = baseResponse.data {
                            continuation.resume(returning: data)
                        } else {
                            continuation.resume(throwing: NSError(
                                domain: "RestaurantService",
                                code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "Failed to fetch pick list"]
                            ))
                        }
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

//
//  SearchService.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/21/25.
//

import Foundation

import Moya

protocol SearchServiceType {
    func searchLocation(query: String) async throws -> SearchListResponse
}

final class SearchService: SearchServiceType {
    private let provider = MoyaProvider<HomeTargetType>.init(withAuth: false)
    
    func searchLocation(query: String) async throws -> SearchListResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.getSearchResultList(query: query)) { result in
                switch result {
                case let .success(response):
                    do {
                        let baseResponse = try response.map(BaseResponse<SearchListResponse>.self)
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
                case let .failure(error):
                    continuation.resume(throwing: SearchError.networkError)
                }
            }
        }
    }
}

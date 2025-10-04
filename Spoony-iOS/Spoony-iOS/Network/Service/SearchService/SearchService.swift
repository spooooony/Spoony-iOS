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
        do {
            let result = try await provider.request(.getSearchResultList(query: query))
                .map(to: BaseResponse<SearchListResponse>.self)
            
            if result.success, let data = result.data {
                return data
            } else if let error = result.error {
                throw SearchError.serverError(message: "\(error)")
            } else {
                throw SearchError.unknownError
            }
        } catch {
            throw error
        }
    }
}

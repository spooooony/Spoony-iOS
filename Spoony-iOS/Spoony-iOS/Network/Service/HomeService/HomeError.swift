//
//  HomeError.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/21/25.
//

import Foundation

enum APIError: LocalizedError {
    case invalidResponse
    case responseError
    case noData
    case decodingError        
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .responseError:
            return "Server returned an error"
        case .noData:
            return "No data available"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}

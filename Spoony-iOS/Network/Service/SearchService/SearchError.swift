//
//  SearchError.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/21/25.
//

import Foundation

enum SearchError: Error {
    case invalidURL
    case networkError
    case decodingError
    case serverError(message: String)
    case unknownError
    
    var errorDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError:
            return "Network error occurred"
        case .decodingError:
            return "Failed to decode response"
        case .serverError(let message):
            return message
        case .unknownError:
            return "Unknown error occurred"
        }
    }
}

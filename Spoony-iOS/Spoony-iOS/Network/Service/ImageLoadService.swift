//
//  ImageLoadService.swift
//  Spoony-iOS
//
//  Created by 최안용 on 5/5/25.
//

import Foundation

import Moya

protocol ImageLoadServiceProtocol {
    func getImage(url: String) async throws -> Data
}

final class ImageLoadService: ImageLoadServiceProtocol {
    private let provider = Providers.imageProvider
    
    func getImage(url: String) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.loadImage(url: url)) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response.data)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

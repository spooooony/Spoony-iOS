//
//  SpoonDrawService.swift
//  Spoony-iOS
//
//  Created on 5/21/25.
//

import Foundation
import Moya

protocol SpoonDrawServiceProtocol {
    func fetchSpoonDrawInfo() async throws -> SpoonDrawResponseWrapper
    func drawSpoon() async throws -> SpoonDrawResponse
}

final class SpoonDrawService: SpoonDrawServiceProtocol {
    private let provider = MoyaProvider<SpoonDrawTargetType>.init(plugins: [SpoonyLoggingPlugin()])
    
    func fetchSpoonDrawInfo() async throws -> SpoonDrawResponseWrapper {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.getSpoonDrawInfo) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(SpoonDrawResponseWrapper.self)
                        continuation.resume(returning: responseDto)
                    } catch {
                        print("스푼 정보 디코딩 에러: \(error)")
                        continuation.resume(throwing: SNError.decodeError)
                    }
                case .failure(let error):
                    print("스푼 정보 API 에러: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func drawSpoon() async throws -> SpoonDrawResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.drawSpoon) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<SpoonDrawResponse>.self)
                        guard let data = responseDto.data else {
                            continuation.resume(throwing: SNError.noData)
                            return
                        }
                        continuation.resume(returning: data)
                    } catch {
                        print("스푼 뽑기 디코딩 에러: \(error)")
                        continuation.resume(throwing: SNError.decodeError)
                    }
                case .failure(let error):
                    print("스푼 뽑기 API 에러: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

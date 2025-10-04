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
        do {
            let result = try await provider.request(.getSpoonDrawInfo)
                .map(to: SpoonDrawResponseWrapper.self)
            
            return result
        } catch {
            throw error
        }
    }
    
    func drawSpoon() async throws -> SpoonDrawResponse {
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

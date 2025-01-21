//
//  ReportService.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/22/25.
//

import Foundation

import Moya

protocol ReportProtocol {
    func reportPost(
        postId: Int,
        report: ReportType,
        description: String
    ) async throws
}

final class DefaultReportService: ReportProtocol {
    let provider = Providers.explorProvider
    
    func reportPost(
        postId: Int,
        report: ReportType,
        description: String
    ) async throws {
        let request = ReportRequest(
            postId: postId,
            userId: Config.userId,
            reportType: report.rawValue,
            reportDetail: description
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.reportPost(report: request)) { result in
                switch result {
                case .success(let response):
                    do {
                        let dataDto = try response.map(BaseResponse<BlankData>.self)
                        let success = dataDto.success
                        
                        if success {
                            continuation.resume()
                        } else {
                            continuation.resume(throwing: NSError(domain: "Report Post Error", code: 0, userInfo: nil))
                        }
                    } catch {
                        continuation.resume(throwing: error)
                    }
                    
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

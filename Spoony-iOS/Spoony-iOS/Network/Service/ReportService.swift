//
//  ReportService.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/22/25.
//

import Foundation

import Moya

enum ReportError: Error {
    case reportFailed
}

protocol ReportProtocol {
    func reportPost(
        postId: Int,
        report: PostReportType,
        description: String
    ) async throws
    
    func reportUser(
        targetUserId: Int,
        report: UserReportType,
        description: String
    ) async throws
}

final class DefaultReportService: ReportProtocol {
    let provider = Providers.explorProvider
    
    func reportPost(
        postId: Int,
        report: PostReportType,
        description: String
    ) async throws {
        let request = PostReportRequest(
            postId: postId,
            reportType: report.key,
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
                            continuation.resume(throwing: ReportError.reportFailed)
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
    
    func reportUser(
        targetUserId: Int,
        report: UserReportType,
        description: String
    ) async throws {
        let request: UserReportRequest = .init(
            targetUserId: targetUserId,
            userReportType: report.key,
            reportDetail: description
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.reportUser(report: request)) { result in
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

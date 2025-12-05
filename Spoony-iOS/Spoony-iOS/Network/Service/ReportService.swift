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
        do {
            let request = PostReportRequest(
                postId: postId,
                reportType: report.key,
                reportDetail: description
            )
            
            let result = try await provider.request(.reportPost(report: request))
                .map(to: BaseResponse<BlankData>.self)
            
            if result.success {
                return
            } else {
                throw ReportError.reportFailed
            }
        } catch {
            throw error
        }
    }
    
    func reportUser(
        targetUserId: Int,
        report: UserReportType,
        description: String
    ) async throws {
        do {
            let request: UserReportRequest = .init(
                targetUserId: targetUserId,
                userReportType: report.key,
                reportDetail: description
            )
            
            let result = try await provider.request(.reportUser(report: request))
                .map(to: BaseResponse<BlankData>.self)
            
            if result.success {
                return
            } else {
                throw ReportError.reportFailed
            }
        } catch {
            throw error
        }
    }
}

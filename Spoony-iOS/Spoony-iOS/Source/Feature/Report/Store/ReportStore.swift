//
//  ReportStore.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/22/25.
//

import Foundation

final class ReportStore: ObservableObject {
    private let network: ReportProtocol = DefaultReportService()
    
    @Published private(set) var selectedReport: ReportType = .ADVERTISEMENT
    
    func changeReportType(report: ReportType) {
        selectedReport = report
    }
    
    // MARK: - Network
    func postReport(
        postId: Int,
        description: String
    ) async throws {
        try await network.reportPost(
            postId: postId,
            report: selectedReport,
            description: description
        )
    }
}

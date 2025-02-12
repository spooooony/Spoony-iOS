//
//  ReportStore.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/22/25.
//

import Foundation

final class ReportStore: ObservableObject {
    private let network: ReportProtocol = DefaultReportService()
    private var navigationManager: NavigationManager
    
    @Published private(set) var state: ReportState = ReportState()
    
    init(navigationManager: NavigationManager) {
        self.navigationManager = navigationManager
    }
    
    func dispatch(_ intent: ReportIntent) {
        switch intent {
        case .reportReasonButtonTapped(let report):
            changeReportType(report: report)
        case .reportPostButtonTapped(let postId):
            sendReport(postId: postId, description: state.description)
        case .backButtonTapped:
            navigationManager.pop(1)
        case .descriptionChanged(let newValue):
            state.description = newValue
        case .backgroundTapped: break
        case .isErrorChanged(let newValue):
            state.isError = newValue
        case .onAppear(let navigationManager):
            self.navigationManager = navigationManager
        }
    }
}

extension ReportStore {
    private func changeReportType(report: ReportType) {
        state.selectedReport = report
    }
    
    private func sendReport(postId: Int, description: String) {
        Task {
            do {
                try await postReport(postId: postId, description: description)
                await MainActor.run {
                    navigationManager.popup = .reportSuccess(action: { [weak self] in
                        self?.navigationManager.pop(2)
                    })
                }
            } catch {
                print("report post failed!")
            }
        }
    }
    
    // MARK: - Network
    private func postReport(
        postId: Int,
        description: String
    ) async throws {
        try await network.reportPost(
            postId: postId,
            report: state.selectedReport,
            description: description
        )
    }
    
}

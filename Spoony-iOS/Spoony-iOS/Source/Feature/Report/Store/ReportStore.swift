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
    
    init(navigationManager: NavigationManager) {
        self.navigationManager = navigationManager
    }
    
    @Published private(set) var state: ReportState = ReportState()
    
    func dispatch(_ intent: ReportIntent) {
        switch intent {
        case .reportReasonButtonTapped(let report):
            changeReportType(report: report)
        case .reportPostButtonTapped(let postId):
            sendReport(postId: postId, description: state.description)
        case .descriptionChanged(let newValue):
            state.description = newValue
        case .backgroundTapped: break
        case .isErrorChanged(let newValue):
            state.isError = newValue    
        case .backButtonTapped:
            navigationManager.dispatch(.pop(1))
        case .onAppear(let manager):
            navigationManager = manager
        }
    }
}

extension ReportStore {
    private func changeReportType(report: ReportType) {
        state.selectedReport = report
    }
    
    private func sendReport(postId: Int, description: String) {
        navigationManager.dispatch(.showPopup(.reportSuccess(action: { [weak self] in
            self?.navigationManager.dispatch(.pop(2))
        })))
        
        Task {
            try await postReport(postId: postId, description: description)
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

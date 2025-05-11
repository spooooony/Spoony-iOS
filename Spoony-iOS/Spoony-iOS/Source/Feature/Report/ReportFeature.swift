//
//  ReportFeature.swift
//  Spoony-iOS
//
//  Created by 최주리 on 5/11/25.
//

import Foundation

import ComposableArchitecture

@Reducer
struct ReportFeature {
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
        
        var postId: Int = 0
        var selectedReport: ReportType = .advertisement
        var description: String = ""
        var isError: Bool = true
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case reportReasonButtonTapped(ReportType)
        case reportPostButtonTapped(Int)
        case routeToExploreScreen
    }
    
    @Dependency(\.reportService) var reportService: ReportProtocol
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce {
            state,
            action in
            
            switch action {
            case .reportReasonButtonTapped(let type):
                state.selectedReport = type
                return .none
            case .reportPostButtonTapped:
                return .run { [state] send in
                    do {
                        try await reportService.reportPost(
                            postId: state.postId,
                            report: state.selectedReport,
                            description: state.description
                        )
                    } catch {
                        // 에러 처리
                    }
                }
            case .routeToExploreScreen:
                return .none
            case .binding:
                return .none
            }
        }
    }
}

private enum ReportServiceKey: DependencyKey {
    static let liveValue: ReportProtocol = DefaultReportService()
}

extension DependencyValues {
    var reportService: ReportProtocol {
        get { self[ReportServiceKey.self] }
        set { self[ReportServiceKey.self] = newValue }
    }
}

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
        
        var postId: Int = -1
        var targetUserId: Int = -1
        var reportType: ReportType = .post
        var selectedPostReport: PostReportType = .advertisement
        var selectedUserReport: UserReportType = .advertisement
        var description: String = ""
        var isError: Bool = true
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case reportPostReasonButtonTapped(PostReportType)
        case reportUserReasonButtonTapped(UserReportType)
        case reportPostButtonTapped
        case routeToExploreScreen
    }
    
    @Dependency(\.reportService) var reportService: ReportProtocol
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                if state.postId != -1 {
                    state.reportType = .post
                } else if state.targetUserId != -1 {
                    state.reportType = .user
                }
                print("report type: \(state.reportType)")
                return .none
            case .reportPostReasonButtonTapped(let type):
                state.selectedPostReport = type
                return .none
            case .reportUserReasonButtonTapped(let type):
                state.selectedUserReport = type
                return .none
            case .reportPostButtonTapped:
                return .run { [state] send in
                    do {
                        switch state.reportType {
                        case .post:
                            try await reportService.reportPost(
                                postId: state.postId,
                                report: state.selectedPostReport,
                                description: state.description
                            )
                        case .user:
                            try await reportService.reportUser(
                                targetUserId: state.targetUserId,
                                report: state.selectedUserReport,
                                description: state.description
                            )
                        }
                        await send(.routeToExploreScreen)
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



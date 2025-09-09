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
        
        var isAlertPresented: Bool = false
        var alertType: AlertType = .normalButtonOne
        var alert: Alert = .init(
            title: "테스트",
            confirmButtonTitle: "테스트",
            cancelButtonTitle: "테스트",
            imageString: nil
        )
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case reportPostReasonButtonTapped(PostReportType)
        case reportUserReasonButtonTapped(UserReportType)
        case reportPostButtonTapped
        
        case presentAlert(AlertType, Alert)
        
        // MARK: - Route Action: 화면 전환 이벤트를 상위 Reducer에 전달 시 사용
        case delegate(Delegate)
        enum Delegate: Equatable {
            case routeToPreviousScreen
            case routeToRoot
            case presentToast(message: String)
        }
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
                        await send(
                            .presentAlert(
                                .normalButtonOne,
                                Alert(
                                    title: "신고가 접수되었어요",
                                    confirmButtonTitle: "확인",
                                    cancelButtonTitle: nil,
                                    imageString: nil
                                )
                            )
                        )
                    } catch {
                        await send(.delegate(.presentToast(message: "서버에 연결할 수 없습니다.\n잠시 후 다시 시도해 주세요.")))
                    }
                }
                
            case let .presentAlert(type, alert):
                state.alertType = type
                state.alert = alert
                state.isAlertPresented = true
                return .none
                
            case .delegate:
                return .none
                
            case .binding:
                return .none
            }
        }
    }
}

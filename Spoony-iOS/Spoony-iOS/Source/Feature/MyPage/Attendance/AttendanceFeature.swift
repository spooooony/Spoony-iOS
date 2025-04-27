//
//  AttendanceFeature.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/17/25.
//

import Foundation

import ComposableArchitecture

@Reducer
struct AttendanceFeature {
    @ObservableState
    struct State: Equatable {
        var selectedDays: Set<String> = ["월", "화"]
        let dateRange = "2025. 03. 24 (월) ~ 2025. 03. 30 (일)"
        let weekdays = ["월", "화", "수", "목", "금", "토", "일"]
        let noticeItems = [
            "출석체크는 매일 자정에 리셋 되어요",
            "1일 1회 무료로 참여 가능해요",
            "신규 가입 시 5개의 스푼을 적립해 드려요"
        ]
        
        static let initialState = State()
    }
    
    enum Action {
        case routeToPreviousScreen
        case toggleDay(String)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .routeToPreviousScreen:
                return .none
                
            case let .toggleDay(day):
                if state.selectedDays.contains(day) {
                    state.selectedDays.remove(day)
                } else {
                    state.selectedDays.insert(day)
                }
                return .none
            }
        }
    }
}

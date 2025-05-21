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
        let dateRange: String
        let weekdays = ["월", "화", "수", "목", "금", "토", "일"]
        let noticeItems = [
            "출석체크는 매일 자정에 리셋 되어요",
            "1일 1회 무료로 참여 가능해요",
            "신규 가입 시 5개의 스푼을 적립해 드려요"
        ]
        
        static let initialState = State(
            dateRange: Self.getCurrentWeekDateRange()
        )
        
        static func getCurrentWeekDateRange() -> String {
            let calendar = Calendar.current
            let today = Date()
            
            let weekday = calendar.component(.weekday, from: today)
            let daysToMonday = (weekday + 5) % 7
            
            guard let monday = calendar.date(byAdding: .day, value: -daysToMonday, to: today),
                  let sunday = calendar.date(byAdding: .day, value: 6 - daysToMonday, to: today) else {
                return "날짜를 가져올 수 없습니다"
            }
            
            let koreanWeekdays = ["일", "월", "화", "수", "목", "금", "토"]
            let mondayWeekday = koreanWeekdays[calendar.component(.weekday, from: monday) - 1]
            let sundayWeekday = koreanWeekdays[calendar.component(.weekday, from: sunday) - 1]
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy. MM. dd"
            dateFormatter.locale = Locale(identifier: "ko_KR")
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
            
            let mondayString = dateFormatter.string(from: monday)
            let sundayString = dateFormatter.string(from: sunday)
            
            return "\(mondayString) (\(mondayWeekday)) ~ \(sundayString) (\(sundayWeekday))"
        }
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

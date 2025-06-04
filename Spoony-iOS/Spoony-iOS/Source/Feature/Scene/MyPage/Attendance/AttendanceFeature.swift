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
        var isLoading: Bool = false
        var errorMessage: String? = nil
        var spoonDrawData: SpoonDrawResponseWrapper.SpoonDrawData? = nil
        
        var spoonCount: Int = 0
        var isLoadingSpoonCount: Bool = false
        var spoonCountErrorMessage: String? = nil
        
        var dateRange: String
        var currentWeekDates: [Date] = []
        var weekdays = ["월", "화", "수", "목", "금", "토", "일"]
        var weekdayDateMap: [String: Date] = [:]
        var attendedWeekdays: [String: SpoonDrawResponse] = [:]
        
        var selectedDay: String? = nil
        var showDrawResultPopup: Bool = false
        var lastDrawnSpoon: SpoonDrawResponse? = nil
        
        var showDailySpoonPopup: Bool = false
        var isDrawingSpoon: Bool = false
        var drawnSpoon: SpoonDrawResponse? = nil
        var spoonDrawError: String? = nil
        var hasVisitedToday: Bool = false
        
        let noticeItems = [
            "출석체크는 매일 자정에 리셋 되어요",
            "1일 1회 무료로 참여 가능해요",
            "신규 가입 시 5개의 스푼을 적립해 드려요"
        ]
        
        static let initialState = State(
            dateRange: Self.getCurrentWeekDateRange().0,
            currentWeekDates: Self.getCurrentWeekDateRange().1,
            weekdayDateMap: Self.getWeekdayDateMap(Self.getCurrentWeekDateRange().1)
        )
        
        static func getCurrentWeekDateRange() -> (String, [Date]) {
            let calendar = Calendar.current
            let today = Date()
            
            let weekday = calendar.component(.weekday, from: today)
            let daysToMonday = (weekday + 5) % 7
            
            guard let monday = calendar.date(byAdding: .day, value: -daysToMonday, to: today) else {
                return ("날짜를 가져올 수 없습니다", [])
            }
            
            var weekDates: [Date] = []
            for i in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: i, to: monday) {
                    weekDates.append(date)
                }
            }
            
            let koreanWeekdays = ["일", "월", "화", "수", "목", "금", "토"]
            let mondayWeekday = koreanWeekdays[calendar.component(.weekday, from: monday) - 1]
            let sundayWeekday = koreanWeekdays[calendar.component(.weekday, from: weekDates.last ?? monday) - 1]
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy. MM. dd"
            dateFormatter.locale = Locale(identifier: "ko_KR")
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
            
            let mondayString = dateFormatter.string(from: monday)
            let sundayString = dateFormatter.string(from: weekDates.last ?? monday)
            
            return ("\(mondayString) (\(mondayWeekday)) ~ \(sundayString) (\(sundayWeekday))", weekDates)
        }
        
        static func getWeekdayDateMap(_ dates: [Date]) -> [String: Date] {
            let koreanWeekdays = ["일", "월", "화", "수", "목", "금", "토"]
            let calendar = Calendar.current
            
            var weekdayDateMap: [String: Date] = [:]
            for date in dates {
                let weekdayIndex = calendar.component(.weekday, from: date) - 1
                let koreanWeekday = koreanWeekdays[weekdayIndex]
                weekdayDateMap[koreanWeekday] = date
            }
            
            return weekdayDateMap
        }
        
        static func dateFromString(_ dateString: String) -> Date? {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "ko_KR")
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
            
            return dateFormatter.date(from: dateString)
        }
        
        static func stringFromDate(_ date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "ko_KR")
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
            
            return dateFormatter.string(from: date)
        }
        
        var hasDrawnSpoonToday: Bool {
            guard let spoonDrawData = spoonDrawData else { return false }
            
            let today = Self.stringFromDate(Date())
            
            return spoonDrawData.spoonDrawResponseDTOList.contains { response in
                response.localDate == today
            }
        }
        
        var isTodayAttended: Bool {
            let calendar = Calendar.current
            let today = Date()
            let koreanWeekdays = ["일", "월", "화", "수", "목", "금", "토"]
            let weekdayIndex = calendar.component(.weekday, from: today) - 1
            let todayWeekday = koreanWeekdays[weekdayIndex]
            
            return attendedWeekdays.keys.contains(todayWeekday)
        }
        
        var todayWeekday: String {
            let calendar = Calendar.current
            let today = Date()
            let koreanWeekdays = ["일", "월", "화", "수", "목", "금", "토"]
            let weekdayIndex = calendar.component(.weekday, from: today) - 1
            return koreanWeekdays[weekdayIndex]
        }
        
        mutating func updateAttendedWeekdays() {
            guard let spoonDrawData = spoonDrawData else {
                attendedWeekdays = [:]
                return
            }
            
            var newAttendedWeekdays: [String: SpoonDrawResponse] = [:]
            
            for response in spoonDrawData.spoonDrawResponseDTOList {
                for (day, date) in weekdayDateMap {
                    let dateString = Self.stringFromDate(date)
                    if response.localDate == dateString {
                        newAttendedWeekdays[day] = response
                    }
                }
            }
            
            attendedWeekdays = newAttendedWeekdays
        }
    }

    enum Action {
        case routeToPreviousScreen
        case onAppear
        case fetchSpoonDrawInfo
        case spoonDrawResponse(TaskResult<SpoonDrawResponseWrapper>)
        case drawSpoon(weekday: String)
        case drawSpoonResponse(TaskResult<SpoonDrawResponse>)
        case dismissDrawResultPopup
        
        case fetchSpoonCount
        case spoonCountResponse(TaskResult<Int>)
        
        case checkDailyVisit
        case setShowDailySpoonPopup(Bool)
        case drawDailySpoon
        case dailySpoonDrawResponse(TaskResult<SpoonDrawResponse>)
    }
    
    @Dependency(\.spoonDrawService) var spoonDrawService
    @Dependency(\.homeService) var homeService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .routeToPreviousScreen:
                return .none
                
            case .onAppear:
                return .merge(
                    .send(.fetchSpoonDrawInfo),
                    .send(.fetchSpoonCount)
                )
                
            case .checkDailyVisit:
                let hasDrawnSpoonToday = state.hasDrawnSpoonToday
                
                if !hasDrawnSpoonToday {
                    return .send(.setShowDailySpoonPopup(true))
                }
                return .none
                
            case let .setShowDailySpoonPopup(show):
                state.showDailySpoonPopup = show
                if !show {
                    state.drawnSpoon = nil
                    state.spoonDrawError = nil
                    state.isDrawingSpoon = false
                }
                return .none
                
            case .drawDailySpoon:
                state.isDrawingSpoon = true
                state.spoonDrawError = nil
                
                return .run { send in
                    let result = await TaskResult { try await homeService.drawDailySpoon() }
                    await send(.dailySpoonDrawResponse(result))
                }
                
            case let .dailySpoonDrawResponse(.success(response)):
                state.isDrawingSpoon = false
                state.drawnSpoon = response
                
                return .merge(
                    .send(.fetchSpoonCount),
                    .send(.fetchSpoonDrawInfo)
                )
                
            case let .dailySpoonDrawResponse(.failure(error)):
                state.isDrawingSpoon = false
                state.spoonDrawError = error.localizedDescription
                print("스푼 뽑기 오류: \(error.localizedDescription)")
                return .none
                
            case .fetchSpoonDrawInfo:
                state.isLoading = true
                state.errorMessage = nil
                
                return .run { send in
                    await send(.spoonDrawResponse(
                        TaskResult { try await spoonDrawService.fetchSpoonDrawInfo() }
                    ))
                }
                
            case let .spoonDrawResponse(.success(response)):
                state.isLoading = false
                if response.success {
                    state.spoonDrawData = response.data
                    state.updateAttendedWeekdays()
                    
                    return .send(.checkDailyVisit)
                } else if let errorMessage = response.error?.message {
                    state.errorMessage = errorMessage
                }
                return .none
                
            case let .spoonDrawResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                
            case .fetchSpoonCount:
                state.isLoadingSpoonCount = true
                state.spoonCountErrorMessage = nil
                return .run { send in
                    await send(.spoonCountResponse(
                        TaskResult { try await homeService.fetchSpoonCount() }
                    ))
                }
                
            case let .spoonCountResponse(.success(count)):
                state.isLoadingSpoonCount = false
                state.spoonCount = count
                state.spoonCountErrorMessage = nil
                return .none
                
            case let .spoonCountResponse(.failure(error)):
                state.isLoadingSpoonCount = false
                state.spoonCount = 0
                print("Error fetching spoon count: \(error)")
                return .none
                
            case let .drawSpoon(weekday):
                guard !state.isLoading,
                      !state.attendedWeekdays.keys.contains(weekday) else {
                    return .none
                }
                
                state.isLoading = true
                state.selectedDay = weekday
                
                return .run { send in
                    await send(.drawSpoonResponse(
                        TaskResult { try await spoonDrawService.drawSpoon() }
                    ))
                }
                
            case let .drawSpoonResponse(.success(response)):
                state.isLoading = false
                state.lastDrawnSpoon = response
                state.showDrawResultPopup = true
                
                return .merge(
                    .send(.fetchSpoonDrawInfo),
                    .send(.fetchSpoonCount)
                )
                
            case let .drawSpoonResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = "스푼 뽑기 실패: \(error.localizedDescription)"
                state.selectedDay = nil
                return .none
                
            case .dismissDrawResultPopup:
                state.showDrawResultPopup = false
                state.lastDrawnSpoon = nil
                state.selectedDay = nil
                return .none
            }
        }
    }
}

//
//  DatePickerManager.swift
//  Spoony-iOS
//
//  Created by 최안용 on 4/13/25.
//

import Foundation

final class DatePickerManager {
    static let shared = DatePickerManager()
    
    private let calendar = Calendar.current
    private let today = Date()
    
    func getYears() -> [String] {
        let ageLimit = 14
        guard let maxYearDate = calendar.date(byAdding: .year, value: -ageLimit, to: today) else {
            return []
        }
        
        let maxYear = calendar.component(.year, from: maxYearDate)
        
        return (1900...maxYear).map { String($0) }
    }
    
    func getMonths() -> [String] {
        return (1...12).map { String(format: "%02d", $0) }
    }
    
    func getDays(year: String, month: String) -> [String] {
        guard let year = Int(year), let month = Int(month) else {
            return []
        }
        
        var components = DateComponents()
        components.year = year
        components.month = month
        
        guard let date = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: date) else {
            return []
        }
        
        return range.map { String(format: "%02d", $0) }
    }
}

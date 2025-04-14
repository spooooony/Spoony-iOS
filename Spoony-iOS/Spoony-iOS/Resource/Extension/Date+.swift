//
//  Date+.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/2/25.
//

import Foundation

extension Date {
    var relativeTimeNamed: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

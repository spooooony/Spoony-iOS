//
//  Date+.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/2/25.
//

import Foundation

extension Date {
    var relativeTimeNamed: String {
        let now = Date()
        let secondsAgo = Int(now.timeIntervalSince(self))
        
        if secondsAgo < 60 {
            return "방금 전"
        } else if secondsAgo < 60 * 60 {
            let minutes = secondsAgo / 60
            return "약 \(minutes)분 전"
        } else if secondsAgo < 60 * 60 * 24 {
            let hours = secondsAgo / (60 * 60)
            return "약 \(hours)시간 전"
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "yyyy년 mm월 dd일"
            return formatter.string(from: self)
        }
    }
}

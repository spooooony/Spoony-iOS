//
//  DateFormatterHelpers.swift
//  Spoony-iOS
//
//  Created by 이명진 on 5/18/25.
//

import Foundation

enum DateFormatterProvider {
    
    /// 마이크로초까지 포함된 ISO 형식 대응 포맷터 (String → Date)
    static let customISOFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX") // 중요
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    /// 화면 표시용 포맷터 (Date → "2025년 04월 19일")
    static let koreanDisplayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter
    }()
}

//
//  String+.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/15/25.
//

import Foundation

extension String {
    func splitZeroWidthSpace() -> String {
        return self.split(separator: "").joined(separator: "\u{200B}")
    }
    
    /// 날짜 문자열에서 yyyy-MM-dd 형식으로 변환하는 함수 (DataFormmatter 사용하는 것보다 효과적이라 적용함)
    func toFormattedDateString() -> String {
        return String(self.prefix(10))
    }
}

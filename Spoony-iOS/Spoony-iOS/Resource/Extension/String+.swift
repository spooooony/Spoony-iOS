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
    
    func removeEmogi() -> String {
        let regexString = "[^가-힣\\u3131-\\u314E\\u314F-\\u3163a-zA-Z0-9!@#$%^&*()_+\\-=\\[\\]{};':“”\"\\\\|,.<>/?£¥•~₩‘’\\s]+"
        guard let regex = try? Regex(regexString) else { return self }
        
        return self.replacing(regex, with: "")
    }
    
    func removeSpecialCharacter() -> String {
        let regexString = "[^a-zA-Zㄱ-ㅎㅏ-ㅣ가-힣\\s]"
        
        guard let regex = try? Regex(regexString) else { return self }
        
        return self.replacing(regex, with: "")
    }
    
    /// 날짜 문자열에서 yyyy-MM-dd 형식으로 변환하는 함수 (DataFormmatter 사용하는 것보다 효과적이라 적용함)
    func toFormattedDateString() -> String {
        return String(self.prefix(10))
    }
}

//
//  String+.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/15/25.
//

import Foundation

extension String {
    
    var toKoreanDateString: String {
        guard let date = DateFormatterProvider.customISOFormatter.date(from: self) else {
            return self
        }
        
        return DateFormatterProvider.koreanDisplayFormatter.string(from: date)
    }
    
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
}

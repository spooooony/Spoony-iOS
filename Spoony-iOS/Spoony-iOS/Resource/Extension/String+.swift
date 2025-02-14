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
}

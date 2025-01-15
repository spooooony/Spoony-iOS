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
}

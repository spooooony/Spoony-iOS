//
//  AgreeType.swift
//  Spoony-iOS
//
//  Created by 최주리 on 3/30/25.
//

import Foundation

enum AgreeType: CaseIterable {
    case age
    case termsOfUse
    case privacyPolicy
    case locationPolicy
    
    var hasURL: Bool {
        switch self {
        case .age: false
        default: true
        }
    }
}

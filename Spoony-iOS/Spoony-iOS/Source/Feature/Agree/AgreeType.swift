//
//  AgreeType.swift
//  Spoony-iOS
//
//  Created by 최주리 on 3/30/25.
//

import Foundation

enum AgreeType: String, CaseIterable {
    case age
    case termsOfUse
    case privacyPolicy
    case locationPolicy
    
    var title: String {
        switch self {
        case .age:
            "만 14세 이상입니다."
        case .termsOfUse:
            "스푸니 서비스 이용약관"
        case .privacyPolicy:
            "개인정보 처리 방침"
        case .locationPolicy:
            "위치기반 서비스 이용 약관"
        }
    }
    
    var url: String? {
        switch self {
        case .age:
            nil
        case .termsOfUse: ""
        case .privacyPolicy: ""
        case .locationPolicy: ""
        }
    }
}

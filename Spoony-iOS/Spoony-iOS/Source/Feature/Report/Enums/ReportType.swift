//
//  ReportType.swift
//  Spoony-iOS
//
//  Created by 최주리 on 5/11/25.
//

import Foundation

enum ReportType: String, CaseIterable, Encodable {
    case advertisement
    case insult
    case illegalInfo
    case personalInfo
    case duplicate
    case other
    
    var title: String {
        switch self {
        case .advertisement:
            "영리 목적/홍보성 후기"
        case .insult:
            "욕설/인신공격"
        case .illegalInfo:
            "불법정보"
        case .personalInfo:
            "개인정보노출"
        case .duplicate:
            "도배"
        case .other:
            "기타"
        }
    }
    
    var key: String {
        switch self {
        case .advertisement:
            "ADVERTISEMENT"
        case .personalInfo:
            "PERSONAL_INFO"
        case .insult:
            "INSULT"
        case .duplicate:
            "DUPLICATE"
        case .illegalInfo:
            "ILLEGAL_INFO"
        case .other:
            "OTHER"
        }
    }
}

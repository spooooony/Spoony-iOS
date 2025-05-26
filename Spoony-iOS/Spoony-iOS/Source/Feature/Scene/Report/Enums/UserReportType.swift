//
//  UserReportType.swift
//  Spoony-iOS
//
//  Created by 최주리 on 5/12/25.
//

import Foundation

enum UserReportType: CaseIterable, ReportTypeProtocol, Equatable {
    case advertisement
    case insult
    case duplicate
    case copyright
    case other
    
    var title: String {
        switch self {
        case .advertisement:
            "영리 목적/홍보성 후기"
        case .insult:
            "욕설/인신공격"
        case .duplicate:
            "도배"
        case .copyright:
            "명예 회손 및 저작권 침해"
        case .other:
            "기타"
        }
    }
    
    var key: String {
        switch self {
        case .advertisement:
            "PROMOTIONAL_CONTENT"
        case .insult:
            "INSULT"
        case .duplicate:
            "DUPLICATE"
        case .copyright:
            "REPUTATION_AND_COPYRIGHT_VIOLATION"
        case .other:
            "OTHER"
        }
    }
        
}

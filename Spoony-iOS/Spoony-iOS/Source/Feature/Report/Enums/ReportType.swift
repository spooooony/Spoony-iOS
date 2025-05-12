//
//  ReportType.swift
//  Spoony-iOS
//
//  Created by 최주리 on 5/12/25.
//

import Foundation

enum ReportType: Equatable {
    case user
    case post
    
    var title: String {
        switch self {
        case .user:
            "유저를 신고하는 이유가 무엇인가요?"
        case .post:
            "후기를 신고하는 이유가 무엇인가요?"
        }
    }
}

protocol ReportTypeProtocol: Equatable {
    var title: String { get }
    var key: String { get }
}


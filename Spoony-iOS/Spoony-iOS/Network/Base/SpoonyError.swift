//
//  SpoonyError.swift
//  Spoony-iOS
//
//  Created by 이명진 on 2/7/25.
//

import Foundation

enum SNError: Error {
    case networkFail
    case decodeError
    case etc
    
    var description: String {
        switch self {
        case .networkFail:
            return "네트워크 연결이 안되어 있습니다."
        case .decodeError:
            return "디코딩에 실패했습니다."
        case .etc:
            return "기타 오류가 발생했습니다."
        }
    }
}

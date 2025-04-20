//
//  BaseResponse.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/19/25.
//

import Foundation

struct BaseResponse<T: Codable>: Codable {
    let success: Bool
    let error: T?
    let data: T?
}

/// data가 없는 API 통신에서 사용할 BlankData 구조체
struct BlankData: Codable {
}

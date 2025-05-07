//
//  SignupRequest.swift
//  Spoony-iOS
//
//  Created by 최주리 on 5/3/25.
//

import Foundation

struct SignupRequest: Encodable {
    let platform: String
    let userName: String
    let birth: String?
    let regionId: Int?
    let introduction: String?
}

//
//  RefreshResponse.swift
//  Spoony-iOS
//
//  Created by 최주리 on 5/30/25.
//

import Foundation

struct RefreshResponse: Codable {
    let accessToken: String
    let refreshToken: String
}

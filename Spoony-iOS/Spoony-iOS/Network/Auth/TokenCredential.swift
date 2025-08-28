//
//  TokenCredential.swift
//  Spoony-iOS
//
//  Created by 최주리 on 5/30/25.
//

import Foundation

import Alamofire

struct TokenCredential: AuthenticationCredential, Equatable {
    let accessToken: String
    let refreshToken: String
    // 필수
    var requiresRefresh: Bool = false
}

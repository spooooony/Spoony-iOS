//
//  SignupRequestDTO.swift
//  Spoony-iOS
//
//  Created by 최주리 on 5/3/25.
//

import Foundation

struct SignupRequestDTO: Encodable {
    let platform: String
    let userName: String
    let birth: String?
    let regionId: Int?
    let introduction: String?
    let authCode: String?
}

extension SignupRequestDTO {
    static func toDTO(from info: SignUpEntity, platform: String, code: String?) -> Self {
        return .init(
            platform: platform,
            userName: info.userName,
            birth: info.birth,
            regionId: info.regionId,
            introduction: info.introduction,
            authCode: code
        )
    }
}

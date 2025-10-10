//
//  SignUpMapper.swift
//  Spoony
//
//  Created by 최주리 on 10/10/25.
//

struct SignUpMapper {
    static func toDTO(from info: SignUpEntity, platform: String, code: String?) -> SignupRequest {
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

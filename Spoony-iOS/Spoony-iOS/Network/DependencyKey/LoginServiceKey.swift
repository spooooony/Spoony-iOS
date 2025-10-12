//
//  LoginServiceKey.swift
//  Spoony-iOS
//
//  Created by 최안용 on 5/4/25.
//

import Dependencies

enum SocialLoginServiceKey: DependencyKey {
    static let liveValue: SocialLoginServiceProtocol = DefaultSocialLoginService()
}

enum AuthServiceKey: DependencyKey {
    static let liveValue: AuthServiceProtocol = AuthService()
    static let testValue: AuthServiceProtocol = AuthService()
}

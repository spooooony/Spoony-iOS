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
    static let liveValue: AuthProtocol = DefaultAuthService()
    static let testValue: AuthProtocol = MockAuthService()
}

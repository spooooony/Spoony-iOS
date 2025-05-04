//
//  LoginServiceKey.swift
//  Spoony-iOS
//
//  Created by 최안용 on 5/4/25.
//

import Dependencies

enum LoginServiceKey: DependencyKey {
    static let liveValue: LoginServiceProtocol = DefaultLoginService()
}

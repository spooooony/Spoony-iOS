//
//  RegisterServiceKey.swift
//  Spoony-iOS
//
//  Created by 최안용 on 5/4/25.
//

import Dependencies

enum RegisterServiceKey: DependencyKey {
    static let liveValue: RegisterServiceType = RegisterService()
}

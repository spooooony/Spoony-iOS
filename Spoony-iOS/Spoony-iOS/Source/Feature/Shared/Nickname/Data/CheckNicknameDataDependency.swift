//
//  OnboardingRepositoryKey.swift
//  Spoony
//
//  Created by 최주리 on 10/12/25.
//

import Dependencies

enum CheckNicknameRepositoryKey: DependencyKey {
    static let liveValue: CheckNicknameInterface = CheckNicknameRepository(myPageService: MyPageService())
    static let testValue: CheckNicknameInterface = CheckNicknameRepository()
}

extension DependencyValues {
    var checkNicknameRepository: CheckNicknameInterface {
        get { self[CheckNicknameRepositoryKey.self] }
        set { self[CheckNicknameRepositoryKey.self] = newValue }
    }
}

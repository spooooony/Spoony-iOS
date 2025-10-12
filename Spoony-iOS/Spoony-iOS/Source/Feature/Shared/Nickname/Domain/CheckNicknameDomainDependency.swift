//
//  CheckNicknameDomainDependency.swift
//  Spoony
//
//  Created by 최주리 on 10/12/25.
//

import Dependencies

enum CheckNicknameDuplicateUseCaseKey: DependencyKey {
    static let liveValue: CheckNicknameDuplicateUseCaseProtocol = CheckNicknameDuplicateUseCase(repository: DependencyValues().checkNicknameRepository)
    static let testValue: CheckNicknameDuplicateUseCaseProtocol = CheckNicknameDuplicateUseCase(repository: DependencyValues().checkNicknameRepository)
}

extension DependencyValues {
    var checkNicknameDuplicateUseCase: CheckNicknameDuplicateUseCaseProtocol {
        get { self[CheckNicknameDuplicateUseCaseKey.self] }
        set { self[CheckNicknameDuplicateUseCaseKey.self] = newValue }
    }
}


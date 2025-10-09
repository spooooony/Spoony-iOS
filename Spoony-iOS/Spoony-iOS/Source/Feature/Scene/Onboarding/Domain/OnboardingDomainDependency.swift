//
//  OnboardingDomainDependency.swift
//  Spoony
//
//  Created by 최주리 on 10/9/25.
//

import Dependencies

enum CheckNicknameDuplicateUseCaseKey: DependencyKey {
    static let liveValue: CheckNicknameDuplicateUseCaseProtocol = CheckNicknameDuplicateUseCase(repository: DependencyValues().onboardingRepository)
    static let testValue: CheckNicknameDuplicateUseCaseProtocol = CheckNicknameDuplicateUseCase(repository: DependencyValues().onboardingRepository)
}

extension DependencyValues {
    var checkNicknameDuplicateUseCase: CheckNicknameDuplicateUseCaseProtocol {
        get { self[CheckNicknameDuplicateUseCaseKey.self] }
        set { self[CheckNicknameDuplicateUseCaseKey.self] = newValue }
    }
}

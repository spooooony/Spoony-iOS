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

enum SignUpUseCaseKey: DependencyKey {
    static let liveValue: SignUpUseCaseProtocol = SignUpUseCase(repository: DependencyValues().onboardingRepository)
    static let testValue: SignUpUseCaseProtocol = SignUpUseCase(repository: DependencyValues().onboardingRepository)
}

extension DependencyValues {
    var checkNicknameDuplicateUseCase: CheckNicknameDuplicateUseCaseProtocol {
        get { self[CheckNicknameDuplicateUseCaseKey.self] }
        set { self[CheckNicknameDuplicateUseCaseKey.self] = newValue }
    }
    
    var signUpUseCase: SignUpUseCaseProtocol {
        get { self[SignUpUseCaseKey.self] }
        set { self[SignUpUseCaseKey.self] = newValue }
    }
}

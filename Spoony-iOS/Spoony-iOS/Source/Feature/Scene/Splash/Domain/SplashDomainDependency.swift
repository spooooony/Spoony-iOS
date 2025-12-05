//
//  SplashDomainDependency.swift
//  Spoony
//
//  Created by 최주리 on 10/2/25.
//

import Dependencies

enum CheckAutoLoginUseCaseKey: DependencyKey {
    static let liveValue: CheckAutoLoginUseCaseProtocol = CheckAutoLoginUseCase(repository: DependencyValues().splashRepository)
    static let testValue: CheckAutoLoginUseCaseProtocol = CheckAutoLoginUseCase(repository: DependencyValues().splashRepository)
}

enum RefreshUseCaseKey: DependencyKey {
    static let liveValue: RefreshUseCaseProtocol = RefreshUseCase(repository: DependencyValues().splashRepository)
    static let testValue: RefreshUseCaseProtocol = RefreshUseCase(repository: DependencyValues().splashRepository)
}

extension DependencyValues {
    var checkAutoLoginUseCase: CheckAutoLoginUseCaseProtocol {
        get { self[CheckAutoLoginUseCaseKey.self] }
        set { self[CheckAutoLoginUseCaseKey.self] = newValue }
    }
    
    var refreshUseCase: RefreshUseCaseProtocol {
        get { self[RefreshUseCaseKey.self] }
        set { self[RefreshUseCaseKey.self] = newValue }
    }
}

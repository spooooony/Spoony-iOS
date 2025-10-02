//
//  SplashDataDependency.swift
//  Spoony
//
//  Created by 최주리 on 10/2/25.
//

import Dependencies

enum SplashRepositoryKey: DependencyKey {
    static let liveValue: SplashInterface = SplashRepository(service: DefaultRefreshService.shared)
    static let testValue: SplashInterface = MockSplashRepository()
}

extension DependencyValues {
    var splashRepository: SplashInterface {
        get { self[SplashRepositoryKey.self] }
        set { self[SplashRepositoryKey.self] = newValue }
    }
}

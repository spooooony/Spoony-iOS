//
//  OnboardingDataDependency.swift
//  Spoony
//
//  Created by 최주리 on 10/9/25.
//

import Dependencies

enum OnboardingRepositoryKey: DependencyKey {
    static let liveValue: OnboardingInterface = OnboardingRepository()
    static let testValue: OnboardingInterface = MockOnboardingRepository()
}

extension DependencyValues {
    var onboardingRepository: OnboardingInterface {
        get { self[OnboardingRepositoryKey.self] }
        set { self[OnboardingRepositoryKey.self] = newValue }
    }
}

//
//  RegisterDataDependency.swift
//  Spoony
//
//  Created by 최안용 on 10/13/25.
//

import Dependencies

enum RegisterRepositoryKey: DependencyKey {
    static var liveValue: RegisterInterface = RegisterRepository(
        service: DependencyValues().registerService
    )
}

extension DependencyValues {
    var registerRepository: RegisterInterface {
        get { self[RegisterRepositoryKey.self] }
        set { self[RegisterRepositoryKey.self] = newValue }
    }
}

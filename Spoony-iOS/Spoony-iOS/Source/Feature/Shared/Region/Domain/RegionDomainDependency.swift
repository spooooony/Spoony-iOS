//
//  RegionDomainDependency.swift
//  Spoony
//
//  Created by 최주리 on 10/9/25.
//

import Dependencies

enum RegionUseCaseKey: DependencyKey {
    static let liveValue: FetchRegionUseCaseProtocol = FetchRegionUseCase(repository: DependencyValues().regionRepository)
    static let testValue: FetchRegionUseCaseProtocol = FetchRegionUseCase(repository: DependencyValues().regionRepository)
}

extension DependencyValues {
    var fetchRegionUseCase: FetchRegionUseCaseProtocol {
        get { self[RegionUseCaseKey.self] }
        set { self[RegionUseCaseKey.self] = newValue }
    }
}

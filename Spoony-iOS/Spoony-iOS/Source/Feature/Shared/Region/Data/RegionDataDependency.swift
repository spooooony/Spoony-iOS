//
//  RegionDataDependency.swift
//  Spoony
//
//  Created by 최주리 on 10/9/25.
//

import Dependencies

enum RegionRepositoryKey: DependencyKey {
    static let liveValue: RegionInterface = RegionRepository(service: DependencyValues().authService)
    static let testValue: RegionInterface = MockRegionRepository()
}

extension DependencyValues {
    var regionRepository: RegionInterface {
        get { self[RegionRepositoryKey.self] }
        set { self[RegionRepositoryKey.self] = newValue }
    }
}

//
//  RefreshServiceKey.swift
//  Spoony
//
//  Created by 최주리 on 9/30/25.
//

import Dependencies

enum CheckAutoLoginKey: DependencyKey {
    static let liveValue: CheckAutoLoginUseCaseProtocol = DefualtCheckAutoLoginUseCase()
    static let testValue: CheckAutoLoginUseCaseProtocol = MockCheckAutoLoginUseCase()
}

enum RefreshKey: DependencyKey {
    static let liveValue: RefreshUseCaseProtocol = DefaultRefreshUseCase()
    static let testValue: RefreshUseCaseProtocol = MockRefreshUseCase()
}

extension DependencyValues {
    var checkAutoLoginUseCase: CheckAutoLoginUseCaseProtocol {
        get { self[CheckAutoLoginKey.self] }
        set { self[CheckAutoLoginKey.self] = newValue }
    }
    
    var refreshUseCase: RefreshUseCaseProtocol {
        get { self[RefreshKey.self] }
        set { self[RefreshKey.self] = newValue }
    }
}

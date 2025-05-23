//
//  DetailUseCaseKey.swift
//  Spoony-iOS
//
//  Created by 최안용 on 5/4/25.
//

import Dependencies

enum DetailUseCaseKey: DependencyKey {
    static let liveValue: DetailUseCase = DetailUseCaseImpl()
    static let testValue: DetailUseCase = MockDetailUseCase()
}

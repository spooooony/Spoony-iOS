//
//  DetailUseCaseKey.swift
//  Spoony-iOS
//
//  Created by 최안용 on 5/4/25.
//

import Dependencies

enum PostUseCaseKey: DependencyKey {
    static let liveValue: PostUseCase = PostUseCaseImpl()
    static let testValue: PostUseCase = MockPostUseCase()
}

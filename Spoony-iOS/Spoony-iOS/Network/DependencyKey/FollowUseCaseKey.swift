//
//  FollowUseCaseKey.swift
//  Spoony-iOS
//
//  Created by 이명진 on 5/11/25.
//

import Dependencies

enum FollowUseCaseKey: DependencyKey {
    static let liveValue: FollowUseCase = FollowUseCaseImpl(repository: FollowRepositoryImpl())
}

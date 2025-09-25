//
//  FollowServiceKey.swift
//  Spoony-iOS
//
//  Created by 이명진 on 5/11/25.
//

import Dependencies

enum FollowServiceKey: DependencyKey {
    static let liveValue: FollowServiceProtocol = DefaultFollowService()
}

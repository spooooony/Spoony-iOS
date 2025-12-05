//
//  PostServiceKey.swift
//  Spoony
//
//  Created by 최주리 on 9/25/25.
//

import Dependencies

enum PostServiceKey: DependencyKey {
    static let liveValue: PostServiceProtocol = DefaultPostService()
}

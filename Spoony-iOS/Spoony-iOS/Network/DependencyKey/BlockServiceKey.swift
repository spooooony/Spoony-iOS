//
//  BlockServiceKey.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 5/26/25.
//

import Dependencies

enum BlockServiceKey: DependencyKey {
    static let liveValue: BlockServiceProtocol = DefaultBlockService()
}

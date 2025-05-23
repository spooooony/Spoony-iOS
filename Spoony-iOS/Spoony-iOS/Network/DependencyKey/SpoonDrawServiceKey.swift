//
//  SpoonDrawServiceKey.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 5/21/25.
//

import Foundation
import Dependencies

enum SpoonDrawServiceKey: DependencyKey {
    static let liveValue: SpoonDrawServiceProtocol = SpoonDrawService()
}

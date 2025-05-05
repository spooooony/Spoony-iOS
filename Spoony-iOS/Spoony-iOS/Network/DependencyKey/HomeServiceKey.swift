//
//  HomeServiceKey.swift
//  Spoony-iOS
//
//  Created by 최안용 on 5/4/25.
//

import Dependencies

enum HomeServiceKey: DependencyKey {
    static let liveValue: HomeServiceType = DefaultHomeService()
}

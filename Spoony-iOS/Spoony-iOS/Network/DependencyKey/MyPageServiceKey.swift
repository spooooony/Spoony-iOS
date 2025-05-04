//
//  MyPageServiceKey.swift
//  Spoony-iOS
//
//  Created by 최안용 on 5/4/25.
//

import Dependencies

enum MyPageServiceKey: DependencyKey {
    static let liveValue: MypageServiceProtocol = MyPageService()
}

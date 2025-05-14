//
//  Providers.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/20/25.
//

import Moya

import Foundation

struct Providers {
    static let homeProvider = MoyaProvider<HomeTargetType>.init(withAuth: true)
    static let explorProvider = MoyaProvider<ExploreTargetType>.init(withAuth: true)
    static let registerProvider = MoyaProvider<RegisterTargetType>.init(withAuth: true)
    static let detailProvider = MoyaProvider<DetailTargetType>.init(withAuth: true)
    static let authProvider = MoyaProvider<AuthTargetType>.init(withAuth: false)
    static let myPageProvider = MoyaProvider<MyPageTargetType>.init(withAuth: true)
    static let imageProvider = MoyaProvider<ImageLoadTargetType>.init(withAuth: true)
    static let followProvider = MoyaProvider<FollowTargetType>.init(withAuth: true)
}

extension MoyaProvider {
    convenience init(withAuth: Bool) {
        if withAuth {
            // TODO: - Interceptor, Logger 구현
            self.init(
                session: Session(),
                plugins: [SpoonyLoggingPlugin()]
            )
        } else {
            // TODO: - Interceptor, Logger 구현
            self.init(plugins: [SpoonyLoggingPlugin()])
        }
    }
}

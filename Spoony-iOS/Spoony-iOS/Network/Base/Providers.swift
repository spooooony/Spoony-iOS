//
//  Providers.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/20/25.
//

import Moya

import Foundation

struct Providers {
    static let homeProvider = MoyaProvider<HomeTargetType>.init(withAuth: false)
    static let explorProvider = MoyaProvider<ExploreTargetType>.init(withAuth: false)
    static let registerProvider = MoyaProvider<RegisterTargetType>.init(withAuth: false)
    static let detailProvider = MoyaProvider<DetailTargetType>.init(withAuth: false)
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

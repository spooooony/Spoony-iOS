//
//  Providers.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/20/25.
//

import Alamofire
import Moya
import Foundation

struct Providers {
    static let homeProvider = MoyaProvider<HomeTargetType>.init(withAuth: true)
    static let explorProvider = MoyaProvider<ExploreTargetType>.init(withAuth: true)
    static let registerProvider = MoyaProvider<RegisterTargetType>.init(withAuth: true)
    static let postProvider = MoyaProvider<PostTargetType>.init(withAuth: true)
    static let authProvider = MoyaProvider<AuthTargetType>.init(withAuth: false)
    static let myPageProvider = MoyaProvider<MyPageTargetType>.init(withAuth: true)
    static let followProvider = MoyaProvider<FollowTargetType>.init(withAuth: true)
    static let spoonDrawProvider = MoyaProvider<SpoonDrawTargetType>.init(withAuth: true)
}

extension MoyaProvider {
    convenience init(withAuth: Bool) {
            if withAuth {
                // 커스텀 TokenInterceptor 사용 (Authenticator 불필요!)
                let tokenInterceptor = TokenInterceptor(refreshService: DefaultRefreshService.shared)
                
                self.init(
                    session: Session(interceptor: tokenInterceptor),
                    plugins: [SpoonyLoggingPlugin()]
                )
            } else {
                self.init(plugins: [SpoonyLoggingPlugin()])
            }
        }
}

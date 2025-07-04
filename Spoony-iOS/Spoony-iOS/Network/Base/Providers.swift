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
            let credential = TokenCredential(
                accessToken: TokenManager.shared.currentToken ?? "",
                refreshToken: TokenManager.shared.currentRefreshToken ?? ""
            )
            let authenticator = TokenAuthenticator(refreshService: DefaultRefreshService.shared)
            let interceptor = AuthenticationInterceptor(authenticator: authenticator, credential: credential)
            self.init(
                session: Session(interceptor: interceptor),
                plugins: [SpoonyLoggingPlugin()]
            )
        } else {
            self.init(plugins: [SpoonyLoggingPlugin()])
        }
    }
}

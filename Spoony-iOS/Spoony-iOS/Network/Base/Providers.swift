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
    static var homeProvider: MoyaProvider<HomeTargetType> {
        return MoyaProvider<HomeTargetType>.init(withAuth: true)
    }
    
    static var explorProvider: MoyaProvider<ExploreTargetType> {
        return MoyaProvider<ExploreTargetType>.init(withAuth: true)
    }
    
    static var registerProvider: MoyaProvider<RegisterTargetType> {
        return MoyaProvider<RegisterTargetType>.init(withAuth: true)
    }
    
    static var postProvider: MoyaProvider<PostTargetType> {
        return MoyaProvider<PostTargetType>.init(withAuth: true)
    }
    
    static var authProvider: MoyaProvider<AuthTargetType> {
        return MoyaProvider<AuthTargetType>.init(withAuth: false)
    }
    
    static var myPageProvider: MoyaProvider<MyPageTargetType> {
        return MoyaProvider<MyPageTargetType>.init(withAuth: true)
    }
    
    static var imageProvider: MoyaProvider<ImageLoadTargetType> {
        return MoyaProvider<ImageLoadTargetType>.init(withAuth: true)
    }
    
    static var followProvider: MoyaProvider<FollowTargetType> {
        return MoyaProvider<FollowTargetType>.init(withAuth: true)
    }
    
    static var spoonDrawProvider: MoyaProvider<SpoonDrawTargetType> {
        return MoyaProvider<SpoonDrawTargetType>.init(withAuth: true)
    }
}

extension MoyaProvider {
    convenience init(withAuth: Bool) {
        if withAuth {
            let accessToken = try? KeychainManager.read(key: .accessToken).get()
            let refreshToken = try? KeychainManager.read(key: .refreshToken).get()
            
            let credential = TokenCredential(
                accessToken: accessToken ?? "",
                refreshToken: refreshToken ?? ""
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

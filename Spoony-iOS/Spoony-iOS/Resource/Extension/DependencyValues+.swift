//
//  DependencyValues+.swift
//  Spoony-iOS
//
//  Created by 최안용 on 5/4/25.
//

import Dependencies

extension DependencyValues {
    var myPageService: MypageServiceProtocol {
        get { self[MyPageServiceKey.self] }
        set { self[MyPageServiceKey.self] = newValue }
    }
    
    var postService: PostServiceProtocol {
        get { self[PostServiceKey.self] }
        set { self[PostServiceKey.self] = newValue }
    }
    
    var homeService: HomeServiceType {
        get { self[HomeServiceKey.self] }
        set { self[HomeServiceKey.self] = newValue }
    }
    
    var socialLoginService: SocialLoginServiceProtocol {
        get { self[SocialLoginServiceKey.self] }
        set { self[SocialLoginServiceKey.self] = newValue }
    }
    
    var authService: AuthProtocol {
        get { self[AuthServiceKey.self] }
        set { self[AuthServiceKey.self] = newValue }
    }
    
    var registerService: RegisterServiceType {
        get { self[RegisterServiceKey.self] }
        set { self[RegisterServiceKey.self] = newValue }
    }
    
    var followService: FollowServiceProtocol {
        get { self[FollowServiceKey.self] }
        set { self[FollowServiceKey.self] = newValue }
    }
    
    var reportService: ReportProtocol {
        get { self[ReportServiceKey.self] }
        set { self[ReportServiceKey.self] = newValue }
    }
    
    var blockService: BlockServiceProtocol {
        get { self[BlockServiceKey.self] }
        set { self[BlockServiceKey.self] = newValue }
    }
    
    var spoonDrawService: SpoonDrawServiceProtocol {
        get { self[SpoonDrawServiceKey.self] }
        set { self[SpoonDrawServiceKey.self] = newValue }
    }
}

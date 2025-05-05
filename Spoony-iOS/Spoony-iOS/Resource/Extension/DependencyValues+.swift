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
    
    var detailUseCase: DetailUseCaseProtocol {
        get { self[DetailUseCaseKey.self] }
        set { self[DetailUseCaseKey.self] = newValue }
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
    
    var imageLoadService: ImageLoadServiceProtocol {
        get { self[ImageLoadServiceKey.self] }
        set { self[ImageLoadServiceKey.self] = newValue }
    }
}

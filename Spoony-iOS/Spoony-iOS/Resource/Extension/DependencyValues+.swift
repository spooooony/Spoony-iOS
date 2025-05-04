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
    
    var loginService: LoginServiceProtocol {
        get { self[LoginServiceKey.self] }
        set { self[LoginServiceKey.self] = newValue }
    }
    
    var registerService: RegisterServiceType {
        get { self[RegisterServiceKey.self] }
        set { self[RegisterServiceKey.self] = newValue }
    }
}

private enum MyPageServiceKey: DependencyKey {
    static let liveValue: MypageServiceProtocol = MyPageService()
}

private enum DetailUseCaseKey: DependencyKey {
    static let liveValue: DetailUseCaseProtocol = DefaultDetailUseCase()
    static let testValue: DetailUseCaseProtocol = MockDetailUseCase()
}

private enum HomeServiceKey: DependencyKey {
    static let liveValue: HomeServiceType = DefaultHomeService()
}

private enum LoginServiceKey: DependencyKey {
    static let liveValue: LoginServiceProtocol = DefaultLoginService()
}

private enum RegisterServiceKey: DependencyKey {
    static let liveValue: RegisterServiceType = RegisterService()
}

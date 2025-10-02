//
//  MockSplashRepository.swift
//  Spoony
//
//  Created by 최주리 on 10/2/25.
//

struct MockSplashRepository: SplashInterface {
    func checkAutoLogin() -> Bool {
        return true
    }
    
    func refresh() async throws { }
}

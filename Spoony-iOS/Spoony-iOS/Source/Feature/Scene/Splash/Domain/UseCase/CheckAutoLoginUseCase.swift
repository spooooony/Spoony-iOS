//
//  CheckAutoLoginUseCase.swift
//  Spoony
//
//  Created by 최주리 on 9/30/25.
//

protocol CheckAutoLoginUseCaseProtocol {
    func execute() -> Bool
}

struct CheckAutoLoginUseCase: CheckAutoLoginUseCaseProtocol {
    private let repository: SplashInterface
    
    init(repository: SplashInterface) {
        self.repository = repository
    }
    
    func execute() -> Bool {
        return repository.checkAutoLogin()
    }
}

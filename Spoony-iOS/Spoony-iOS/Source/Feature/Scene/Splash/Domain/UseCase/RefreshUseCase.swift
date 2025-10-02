//
//  RefreshUseCase.swift
//  Spoony
//
//  Created by 최주리 on 10/2/25.
//

import Foundation

protocol RefreshUseCaseProtocol {
    func execute() async throws
}

struct RefreshUseCase: RefreshUseCaseProtocol {
    private let repository: SplashInterface
    
    init(repository: SplashInterface) {
        self.repository = repository
    }
    
    func execute() async throws {
        try await repository.refresh()
    }
}

//
//  SignupUseCase.swift
//  Spoony
//
//  Created by 최주리 on 10/10/25.
//

/// 회원가입 + 사용자의 닉네임 return
protocol SignUpUseCaseProtocol {
    func execute(info: SignUpEntity) async throws -> String
}

struct SignUpUseCase: SignUpUseCaseProtocol {
    private let repository: OnboardingInterface
    
    init(repository: OnboardingInterface) {
        self.repository = repository
    }
    
    func execute(info: SignUpEntity) async throws -> String {
        try await repository.signup(info: info)
    }
}

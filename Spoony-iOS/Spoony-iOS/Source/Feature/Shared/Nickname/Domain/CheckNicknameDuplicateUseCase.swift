//
//  CheckNicknameDuplicate.swift
//  Spoony
//
//  Created by 최주리 on 10/9/25.
//

protocol CheckNicknameDuplicateUseCaseProtocol {
    func execute(nickname: String) async throws -> Bool
}

struct CheckNicknameDuplicateUseCase: CheckNicknameDuplicateUseCaseProtocol {
    private let repository: CheckNicknameInterface
    
    init(repository: CheckNicknameInterface) {
        self.repository = repository
    }
    
    func execute(nickname: String) async throws -> Bool {
        return try await repository.checkNicknameDuplicate(nickname: nickname)
    }
}

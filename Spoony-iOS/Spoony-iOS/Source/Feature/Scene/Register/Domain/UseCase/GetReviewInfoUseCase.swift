//
//  GetReviewInfoUseCase.swift
//  Spoony
//
//  Created by 최안용 on 10/8/25.
//

protocol GetReviewInfoUseCaseProtocol {
    func execute(postId: Int) async throws -> ReviewInfoEntity
}

struct GetReviewInfoUseCase: GetReviewInfoUseCaseProtocol {
    private let repository: RegisterRepository
    
    init(repository: RegisterRepository) {
        self.repository = repository
    }
    
    func execute(postId: Int) async throws -> ReviewInfoEntity {
        try await repository.getReviewInfo(postId: postId)
    }
}

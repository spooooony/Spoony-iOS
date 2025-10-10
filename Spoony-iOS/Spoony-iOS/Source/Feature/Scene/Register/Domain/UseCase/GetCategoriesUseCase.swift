//
//  GetCategoriesUseCase.swift
//  Spoony
//
//  Created by 최안용 on 10/8/25.
//

protocol GetCategoriesUseCaseProtocol {
    func execute() async throws -> [CategoryChipEntity]
}

struct GetCategoriesUseCase: GetCategoriesUseCaseProtocol {
    private let repository: RegisterRepository
    
    init(repository: RegisterRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [CategoryChipEntity] {
        try await repository.getRegisterCategories()
    }
}

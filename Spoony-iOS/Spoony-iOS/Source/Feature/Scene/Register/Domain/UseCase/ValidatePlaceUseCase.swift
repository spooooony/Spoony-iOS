//
//  ValidatePlaceUseCase.swift
//  Spoony
//
//  Created by 최안용 on 10/8/25.
//

protocol ValidatePlaceUseCaseProtocol {
    func execute(latitude: Double, longitude: Double) async throws -> Bool
}

struct ValidatePlaceUseCase: ValidatePlaceUseCaseProtocol {
    private let repository: RegisterInterface
    
    init(repository: RegisterInterface) {
        self.repository = repository
    }
    
    func execute(latitude: Double, longitude: Double) async throws -> Bool {
        try await repository.validatePlace(latitude: latitude, longitude: longitude)
    }
}

//
//  SearchPlaceUseCase.swift
//  Spoony
//
//  Created by 최안용 on 10/4/25.
//

protocol SearchPlaceUseCaseProtocol {
    func execute(query: String) async throws -> [PlaceInfoEntity]
}

struct SearchPlaceUseCase: SearchPlaceUseCaseProtocol {
    private let repository: RegisterInterface
    
    init(repository: RegisterInterface) {
        self.repository = repository
    }
    
    func execute(query: String) async throws -> [PlaceInfoEntity] {
        try await repository.searchPlace(query: query)
    }
}

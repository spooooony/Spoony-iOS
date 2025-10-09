//
//  FetchRegionUseCase.swift
//  Spoony
//
//  Created by 최주리 on 10/9/25.
//

protocol FetchRegionUseCaseProtocol {
    func fetchRegionList() async throws -> [Region]
}

struct FetchRegionUseCase: FetchRegionUseCaseProtocol {
    private let repository: RegionInterface
    
    init(repository: RegionInterface) {
        self.repository = repository
    }
    
    func fetchRegionList() async throws -> [Region] {
        return try await repository.fetchRegionList()
    }
}

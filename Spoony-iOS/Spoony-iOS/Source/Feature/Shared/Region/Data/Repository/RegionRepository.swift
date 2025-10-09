//
//  RegionService.swift
//  Spoony
//
//  Created by 최주리 on 10/9/25.
//

struct RegionRepository: RegionInterface {
    private let service: AuthProtocol
    
    init(service: AuthProtocol) {
        self.service = service
    }
    
    func fetchRegionList() async throws -> [Region] {
        let list = try await service.getRegionList()
        return list.toEntity()
    }
}

struct MockRegionRepository: RegionInterface {
    func fetchRegionList() async throws -> [Region] {
        return Region.mock()
    }
}

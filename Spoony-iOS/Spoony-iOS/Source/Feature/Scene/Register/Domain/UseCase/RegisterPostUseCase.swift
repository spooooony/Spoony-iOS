//
//  RegisterPostUseCase.swift
//  Spoony
//
//  Created by 최안용 on 10/8/25.
//

import Foundation

protocol RegisterPostUseCaseProtocol {
    func execute(info: RegisterEntity, imagesData: [Data]) async throws -> Bool
}

struct RegisterPostUseCase: RegisterPostUseCaseProtocol {
    private let repository: RegisterInterface
    
    init(repository: RegisterInterface) {
        self.repository = repository
    }
    
    func execute(info: RegisterEntity, imagesData: [Data]) async throws -> Bool {
        try await repository.registerPost(info: info, imagesData: imagesData)
    }
}

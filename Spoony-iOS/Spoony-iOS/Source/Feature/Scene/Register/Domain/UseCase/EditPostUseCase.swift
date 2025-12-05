//
//  EditPostUseCase.swift
//  Spoony
//
//  Created by 최안용 on 10/8/25.
//

import Foundation

protocol EditPostUseCaseProtocol {
    func execute(info: EditEntity, imagesData: [Data]) async throws -> Bool
}

struct EditPostUseCase: EditPostUseCaseProtocol {
    private let repository: RegisterInterface
    
    init(repository: RegisterInterface) {
        self.repository = repository
    }
    
    func execute(info: EditEntity, imagesData: [Data]) async throws -> Bool {
        try await repository.editPost(info: info, imagesData: imagesData)
    }
}

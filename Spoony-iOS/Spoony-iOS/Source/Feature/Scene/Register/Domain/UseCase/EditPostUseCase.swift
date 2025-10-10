//
//  EditPostUseCase.swift
//  Spoony
//
//  Created by 최안용 on 10/8/25.
//

import Foundation

protocol EditPostUseCaseProtocol {
    func execute(
        postId: Int,
        description: String,
        value: Double,
        cons: String,
        categoryId: Int,
        menuList: [String],
        deleteImageUrlList: [String],
        imagesData: [Data]
    ) async throws -> Bool
}

struct EditPostUseCase: EditPostUseCaseProtocol {
    private let repository: RegisterInterface
    
    init(repository: RegisterInterface) {
        self.repository = repository
    }
    
    func execute(
        postId: Int,
        description: String,
        value: Double,
        cons: String,
        categoryId: Int,
        menuList: [String],
        deleteImageUrlList: [String],
        imagesData: [Data]
    ) async throws -> Bool {
        try await repository.editPost(
            postId: postId,
            description: description,
            value: value,
            cons: cons,
            categoryId: categoryId,
            menuList: menuList,
            deleteImageUrlList: deleteImageUrlList,
            imagesData: imagesData
        )
    }
}

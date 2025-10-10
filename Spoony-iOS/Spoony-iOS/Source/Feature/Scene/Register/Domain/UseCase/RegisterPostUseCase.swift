//
//  RegisterPostUseCase.swift
//  Spoony
//
//  Created by 최안용 on 10/8/25.
//

import Foundation

protocol RegisterPostUseCaseProtocol {
    func execute(
        title: String,
        description: String,
        value: Double,
        cons: String?,
        placeName: String,
        placeAddress: String,
        placeRoadAddress: String,
        latitude: Double,
        longitude: Double,
        categoryId: Int,
        menuList: [String],
        imagesData: [Data]
    ) async throws -> Bool
}

struct RegisterPostUseCase: RegisterPostUseCaseProtocol {
    private let repository: RegisterInterface
    
    init(repository: RegisterInterface) {
        self.repository = repository
    }
    
    func execute(
        title: String,
        description: String,
        value: Double,
        cons: String?,
        placeName: String,
        placeAddress: String,
        placeRoadAddress: String,
        latitude: Double,
        longitude: Double,
        categoryId: Int,
        menuList: [String],
        imagesData: [Data]
    ) async throws -> Bool {
        try await repository.registerPost(
            title: title,
            description: description,
            value: value,
            cons: cons,
            placeName: placeName,
            placeAddress: placeAddress,
            placeRoadAddress: placeRoadAddress,
            latitude: latitude,
            longitude: longitude,
            categoryId: categoryId,
            menuList: menuList,
            imagesData: imagesData
        )
    }
}

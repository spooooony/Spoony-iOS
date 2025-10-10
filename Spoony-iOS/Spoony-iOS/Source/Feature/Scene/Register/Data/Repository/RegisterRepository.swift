//
//  RegisterRepository.swift
//  Spoony
//
//  Created by 최안용 on 10/4/25.
//

import Foundation

struct RegisterRepository: RegisterInterface {
    private let service: RegisterServiceType
    
    init(service: RegisterServiceType) {
        self.service = service
    }
    
    func searchPlace(query: String) async throws -> [PlaceInfoEntity] {
        try await service.searchPlace(query: query).toEntity()
    }
    
    func validatePlace(latitude: Double, longitude: Double) async throws -> Bool {
        let request = ValidatePlaceRequestDTO(latitude: latitude, longitude: longitude)
        
        return try await service.validatePlace(request: request).duplicate
    }
    
    func registerPost(
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
        let request = RegisterPostRequestDTO(
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
            menuList: menuList
        )
        
        return try await service.registerPost(request: request, imagesData: imagesData)
    }
    
    func editPost(
        postId: Int,
        description: String,
        value: Double,
        cons: String,
        categoryId: Int,
        menuList: [String],
        deleteImageUrlList: [String],
        imagesData: [Data]
    ) async throws -> Bool {
        let request = EditPostRequestDTO(
            postId: postId,
            description: description,
            value: value,
            cons: cons,
            categoryId: categoryId,
            menuList: menuList,
            deleteImageUrlList: deleteImageUrlList
        )
        
        return try await service.editPost(request: request, imagesData: imagesData)
    }
    
    func getRegisterCategories() async throws -> [CategoryChipEntity] {
        try await service.getRegisterCategories().toEntity()
    }
    
    func getReviewInfo(postId: Int) async throws -> ReviewInfoEntity {
        try await service.getReviewInfo(postId: postId).toEntity()
    }
}

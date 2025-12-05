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
    
    func registerPost(info: RegisterEntity, imagesData: [Data]) async throws -> Bool {
        let request = RegisterPostRequestDTO.toDTO(from: info)
        
        return try await service.registerPost(request: request, imagesData: imagesData)
    }
    
    func editPost(info: EditEntity, imagesData: [Data]) async throws -> Bool {
        let request = EditPostRequestDTO.toDTO(from: info)
        
        return try await service.editPost(request: request, imagesData: imagesData)
    }
    
    func getRegisterCategories() async throws -> [CategoryChipEntity] {
        try await service.getRegisterCategories().toEntity()
    }
    
    func getReviewInfo(postId: Int) async throws -> ReviewInfoEntity {
        try await service.getReviewInfo(postId: postId).toEntity()
    }
}

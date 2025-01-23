//
//  RegisterService.swift
//  Spoony-iOS
//
//  Created by 최안용 on 1/21/25.
//

import Foundation

import Moya

protocol RegisterServiceType {
    func searchPlace(query: String) async throws -> SearchPlaceResponse
    func validatePlace(request: ValidatePlaceRequest) async throws -> ValidatePlaceResponse
    func registerPost(request: RegisterPostRequest, imagesData: [Data]) async throws -> Bool
    func getRegisterCategories() async throws -> RegisterCategoryResponse
}

final class RegisterService: RegisterServiceType {
    private let provider = Providers.registerProvider
    
    func searchPlace(query: String) async throws -> SearchPlaceResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.searchPlace(query: query)) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<SearchPlaceResponse>.self)
                        guard let data = responseDto.data else { return }
                        
                        continuation.resume(returning: data)
                    } catch {
                        
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func validatePlace(request: ValidatePlaceRequest) async throws -> ValidatePlaceResponse {
        return try await withCheckedThrowingContinuation { continutaion in
            provider.request(.validatePlace(request: request)) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<ValidatePlaceResponse>.self)
                        guard let data = responseDto.data else { return }
                        
                        continutaion.resume(returning: data)
                    } catch {
                        continutaion.resume(throwing: error)
                    }
                case .failure(let error):
                    continutaion.resume(throwing: error)
                }
            }
        }
    }
    
    func registerPost(request: RegisterPostRequest, imagesData: [Data]) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.registerPost(request: request, imagesDate: imagesData)) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<BlankData>.self)
                        
                        continuation.resume(returning: responseDto.success)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getRegisterCategories() async throws -> RegisterCategoryResponse {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(.getRegisterCategories) { result in
                switch result {
                case .success(let response):
                    do {
                        let responseDto = try response.map(BaseResponse<RegisterCategoryResponse>.self)
                        guard let data = responseDto.data else { return }
                        
                        continuation.resume(returning: data)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

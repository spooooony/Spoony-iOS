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
    func editPost(request: EditPostRequest, imagesData: [Data]) async throws -> Bool
    func getRegisterCategories() async throws -> CategoryListResponse
    func getReviewInfo(postId: Int) async throws -> ReviewResponse
}

final class RegisterService: RegisterServiceType {
    private let provider = Providers.registerProvider
    
    func searchPlace(query: String) async throws -> SearchPlaceResponse {
        do {
            let result = try await provider.request(.searchPlace(query: query))
                .map(to: BaseResponse<SearchPlaceResponse>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            return data
        } catch {
            throw error
        }
    }
    
    func validatePlace(request: ValidatePlaceRequest) async throws -> ValidatePlaceResponse {
        do {
            let result = try await provider.request(.validatePlace(request: request))
                .map(to: BaseResponse<ValidatePlaceResponse>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            return data
        } catch {
            throw error
        }
    }
    
    func registerPost(request: RegisterPostRequest, imagesData: [Data]) async throws -> Bool {
        do {
            let result = try await provider.request(.registerPost(request: request, imagesDate: imagesData))
                .map(to: BaseResponse<BlankData>.self)
            
            return result.success
        } catch {
            throw error
        }
    }
    
    func editPost(request: EditPostRequest, imagesData: [Data]) async throws -> Bool {
        do {
            let result = try await provider.request(.editPost(request: request, imagesDate: imagesData))
                .map(to: BaseResponse<BlankData>.self)
            
            return result.success
        } catch {
            throw error
        }
    }
    
    func getRegisterCategories() async throws -> CategoryListResponse {
        do {
            let result = try await provider.request(.getRegisterCategories)
                .map(to: BaseResponse<CategoryListResponse>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            return data
        } catch {
            throw error
        }
    }
    
    func getReviewInfo(postId: Int) async throws -> ReviewResponse {
        do {
            let result = try await provider.request(.getReviewInfo(postId: postId))
                .map(to: BaseResponse<ReviewResponse>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            return data
        } catch {
            throw error
        }
    }
}

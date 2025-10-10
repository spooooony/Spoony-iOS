//
//  RegisterInterface.swift
//  Spoony
//
//  Created by 최안용 on 10/4/25.
//

import Foundation

protocol RegisterInterface {
    func searchPlace(query: String) async throws -> [PlaceInfoEntity]
    func validatePlace(latitude: Double, longitude: Double) async throws -> Bool
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
    ) async throws -> Bool 
    func editPost(
        postId: Int,
        description: String,
        value: Double,
        cons: String,
        categoryId: Int,
        menuList: [String],
        deleteImageUrlList: [String],
        imagesData: [Data]
    ) async throws -> Bool
    func getRegisterCategories() async throws -> [CategoryChipEntity]
    func getReviewInfo(postId: Int) async throws -> ReviewInfoEntity
}

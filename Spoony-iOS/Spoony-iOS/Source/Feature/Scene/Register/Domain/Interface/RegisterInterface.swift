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
    func registerPost(info: RegisterEntity, imagesData: [Data]) async throws -> Bool
    func editPost(info: EditEntity, imagesData: [Data]) async throws -> Bool
    func getRegisterCategories() async throws -> [CategoryChipEntity]
    func getReviewInfo(postId: Int) async throws -> ReviewInfoEntity
}

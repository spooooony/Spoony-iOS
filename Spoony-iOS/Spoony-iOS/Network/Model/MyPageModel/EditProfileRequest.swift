//
//  EditProfileRequest.swift
//  Spoony-iOS
//
//  Created by 최안용 on 5/3/25.
//

import Foundation

struct EditProfileRequest: Codable {
    let userName: String
    let regionId: Int?
    let introduction: String
    let birth: String
    let imageLevel: Int
}

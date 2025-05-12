//
//  UserProfileResponse.swift
//  Spoony-iOS
//
//  Created by 최안용 on 5/3/25.
//

import Foundation

struct UserProfileResponse: Codable {
    let userName: String
    let regionName: String
    let introduction: String
    let birth: String
    let imageLevel: Int
}

extension UserProfileResponse {
    func toModel() -> ProfileInfo {
        let birthDateComponents: [String] = birth.split(separator: "-").map { String($0) }
        
        let regionNameComponents: [String] = regionName.split(separator: " ").map { String($0) }
        
        let location = LocationType.allCases.first(where: { $0.rawValue == regionNameComponents[0] })
        
        return .init(
            nickname: userName,
            introduction: introduction,
            birthDate: birthDateComponents,
            regionName: regionName,
            selectedLocation: location ?? .seoul,
            selectedSubLocation: nil,
            imageLevel: imageLevel
        )
    }
}

//
//  UserProfileResponse.swift
//  Spoony-iOS
//
//  Created by 최안용 on 5/3/25.
//

import Foundation

struct UserProfileResponse: Codable {
    let userName: String
    let regionName: String?
    let introduction: String?
    let birth: String?
    let imageLevel: Int
}

extension UserProfileResponse {
    func toModel() -> ProfileInfo {
        let birthDateComponents: [String]
        if let birth = birth, !birth.isEmpty {
            birthDateComponents = birth.split(separator: "-").map { String($0) }
        } else {
            birthDateComponents = ["", "", ""]
        }
        
        let location: LocationType
        let finalRegionName: String
        
        if let regionName = regionName, !regionName.isEmpty {
            let regionNameComponents: [String] = regionName.split(separator: " ").map { String($0) }
            location = LocationType.allCases.first(where: { $0.rawValue == regionNameComponents[0] }) ?? .seoul
            finalRegionName = regionName
        } else {
            location = .seoul
            finalRegionName = ""
        }
        
        return .init(
            nickname: userName,
            introduction: introduction ?? "",
            birthDate: birthDateComponents,
            regionName: finalRegionName,
            selectedLocation: location,
            selectedSubLocation: nil,
            imageLevel: imageLevel
        )
    }
}

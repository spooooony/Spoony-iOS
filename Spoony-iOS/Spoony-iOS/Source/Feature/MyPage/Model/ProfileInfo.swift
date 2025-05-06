//
//  ProfileInfo.swift
//  Spoony-iOS
//
//  Created by 최안용 on 5/3/25.
//

import Foundation

struct ProfileInfo: Equatable {
    let nickname: String
    let introduction: String
    let birthDate: [String]
    let selectedLocation: LocationType
//    let selectedSubLocation: SubLocationType?
    let selectedSubLocation: Region?
    let imageLevel: Int
}

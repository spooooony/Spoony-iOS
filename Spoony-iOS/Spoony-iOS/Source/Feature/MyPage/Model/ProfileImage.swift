//
//  ProfileImage.swift
//  Spoony-iOS
//
//  Created by 최안용 on 5/4/25.
//

import Foundation

struct ProfileImage: Equatable, Hashable {
    let url: String
    let imageLevel: Int
    let unlockCondition: String
    var isUnlocked: Bool
}

//
//  OnboardingUserEntity.swift
//  Spoony-iOS
//
//  Created by 최주리 on 5/4/25.
//

import Foundation

struct OnboardingUserEntity: Equatable {
    let userName: String
    let region: RegionEntity?
    let introduction: String?
    let birth: String?
}



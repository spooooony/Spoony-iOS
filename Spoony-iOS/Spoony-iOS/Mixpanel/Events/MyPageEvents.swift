//
//  MyPageEvents.swift
//  Spoony-iOS
//
//  Created by 최안용 on 7/6/25.
//

import Mixpanel

struct MyPageEvents {
    enum Name {
        static let profileUpdate = "profile_updated"
        static let spoonViewd = "spoon_character_viewed"
    }
    
    enum UpdateFiled: String, CaseIterable {
        case profileImage = "profile_image"
        case nickname = "nickname"
        case bio = "bio"
        case birthdate = "birthdate"
        case activeRegion = "active_region"
        
    }
    
    struct ProfileUpdateProperty: MixpanelProperty {
        var fields: [UpdateFiled]
        
        var dictionary: [String : MixpanelType] {
            ["profile_updated": fields.map { $0.rawValue }]
        }
    }
}

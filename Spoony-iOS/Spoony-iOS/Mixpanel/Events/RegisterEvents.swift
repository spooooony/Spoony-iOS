//
//  RegisterEvents.swift
//  Spoony-iOS
//
//  Created by 최안용 on 7/5/25.
//

import Mixpanel

struct RegisterEvents {
    enum Name {
        static let reivew1Complete = "review_1_completed"
        static let reivew2Complete = "review_2_completed"
    }
    
    struct Review1Property: MixpanelProperty {
        let placeName: String
        let category: String
        let menuCount: Int
        
        var dictionary: [String: MixpanelType] {
            [
                "place_name": placeName,
                "category": category,
                "menu_count": menuCount
            ]
        }
    }
    
    struct Review2Property: MixpanelProperty {
        let reviewLength: Int
        let photoCount: Int
        let hasDisappointment: Bool
        
        var dictionary: [String: MixpanelType] {
            [
                "review_length": reviewLength,
                "photo_count": photoCount,
                "has_disappointment": hasDisappointment
            ]
        }
    }
}

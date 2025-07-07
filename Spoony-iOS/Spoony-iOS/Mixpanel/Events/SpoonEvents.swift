//
//  SpoonEvents.swift
//  Spoony-iOS
//
//  Created by 최안용 on 7/4/25.
//

import Mixpanel

struct SpoonEvents {
    enum Name {
        static let spoonReceived = "spoon_received"
    }
    
    struct SpoonReceivedProperty: MixpanelProperty {
        let spoonCount: Int
        
        var dictionary: [String : MixpanelType] {
            ["spoon_count": spoonCount]
        }                
    }
}

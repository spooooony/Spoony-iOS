//
//  OnboardingEvents.swift
//  Spoony-iOS
//
//  Created by 최안용 on 7/4/25.
//

import Mixpanel

struct OnboardingEvents {
    enum Name {
        static let onboarding1Completed = "onboarding_1_completed"
        static let onboarding2Completed = "onboarding_2_completed"
        static let onboarding2Skiped = "onboarding_2_skipped"
        static let onboarding3Completed = "onboarding_3_completed"
        static let onboarding3Skiped = "onboarding_3_skipped"
    }
    
    struct Onboarding1CompletedProperty: MixpanelProperty {
        let birthdateEntered: Bool
        let activeRegionEntered: Bool
        
        var dictionary: [String: MixpanelType] {
            [
                "birthdate_entered": birthdateEntered,
                "active_region_entered": activeRegionEntered
            ]
        }
    }
    
    struct Onboarding3CompletedProperty: MixpanelProperty {
        let bioLength: Int
        
        var dictionary: [String: MixpanelType] {
            ["bio_length": bioLength]
        }
    }
}

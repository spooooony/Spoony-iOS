//
//  ConversionAnalysisEvents.swift
//  Spoony-iOS
//
//  Created by 최안용 on 7/4/25.
//

import Mixpanel

struct ConversionAnalysisEvents {
    enum Name {
        static let appOpen = "app_open"
        static let signupCompleted = "signup_completed"
        static let loginsuccess = "login_success"
    }
    
    struct AppOpenProperty: MixpanelProperty {
        let isFirstTime: Bool
        
        var dictionary: [String: MixpanelType] {
            ["is_first_time": isFirstTime]
        }
    }
    
    struct SignupProperty: MixpanelProperty {
        let method: SocialType
        
        var dictionary: [String: MixpanelType] {
            ["signup_method": method.rawValue]
        }
    }
}

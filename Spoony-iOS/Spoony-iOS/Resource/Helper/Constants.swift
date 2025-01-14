//
//  Constants.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/2/25.
//

import Foundation

struct Constants {
    
    struct NaverMap {
        static var clientId: String {
            guard let clientId = Bundle.main.object(forInfoDictionaryKey: "NMFClientId") as? String else {
                fatalError("NMFClientId not found in Info.plist")
            }
            return clientId
        }
        
        static var clientSecret: String {
            guard let path = Bundle.main.path(forResource: "PrivacyInfo", ofType: "plist"),
                  let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
                  let clientSecret = dict["ClientSecret"] as? String else {
                fatalError("ClientSecret not found in PrivacyInfo.plist")
            }
            return clientSecret
        }
    }
}

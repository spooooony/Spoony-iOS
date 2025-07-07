//
//  MapEvents.swift
//  Spoony-iOS
//
//  Created by 최안용 on 7/4/25.
//

import Mixpanel

struct MapEvents {
    enum Name {
        static let mapSearched = "map_searched"
    }
    
    enum LoacationType: String {
        case gu
        case dong
        case yeok
        case unKnown
    }
    
    struct MapSearchedProperty: MixpanelProperty {
        let locationType: LoacationType
        let searchTerm: String
        
        var dictionary: [String: MixpanelType] {
            [
                "loaction_type": locationType.rawValue,
                "search_term": searchTerm
            ]
        }
    }
}

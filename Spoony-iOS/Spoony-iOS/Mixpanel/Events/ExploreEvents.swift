//
//  ExploreEvents.swift
//  Spoony-iOS
//
//  Created by 최안용 on 7/4/25.
//

import Mixpanel

struct ExploreEvents {
    enum Name {
        static let sortSelected = "sort_selected"
        static let exploreSearched = "explore_searched"
    }
    
    struct SortSelectedProperty: MixpanelProperty {
        var sortType: SortType
        
        var dictionary: [String: MixpanelType] {
            ["sort_type": sortType.rawValue]
        }
    }
    
    struct ExploreSearchProperty: MixpanelProperty {
        var searchTargetType: ExploreSearchViewType
        let searchTerm: String
        
        var dictionary: [String: MixpanelType] {
            [
                "search_target_type": searchTargetType.rawValue,
                "search_term": searchTerm
            ]
        }
    }
}

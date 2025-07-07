//
//  ReviewEvents.swift
//  Spoony-iOS
//
//  Created by 최안용 on 7/7/25.
//

import Mixpanel

struct ReviewEvents {
    enum Name {
        static let spoonUseIntent = "spoon_use_intent"
        static let spoonUsed = "spoon_used"
        static let spoonUseFailed = "spoon_use_failed"
        static let placeMapSaved = "place_map_saved"
        static let placeMapRemoved = "place_map_removed"
        static let directionClicked = "direction_clicked"
    }
    
    struct ReviewProperty: MixpanelProperty {
        let reviewId: Int
        let authorUserId: Int
        let placeId: Int
        let placeName: String
        let category: String
        let menuCount: Int
        let satisfactionScore: Double
        let reviewLength: Int
        let photoCount: Int
        let hasDisappointment: Bool
        let savedCount: Int
        let isFollowingAuthor: Bool
        
        var dictionary: [String: MixpanelType] {
            [
                "review_id": reviewId,
                "author_user_id": authorUserId,
                "place_id": placeId,
                "place_name": placeName,
                "category": category,
                "menu_count": menuCount,
                "satisfaction_score": satisfactionScore,
                "review_length": reviewLength,
                "photo_count": photoCount,
                "has_disappointment": hasDisappointment,
                "saved_count": savedCount,
                "is_following_author": isFollowingAuthor
            ]
        }
    }
}

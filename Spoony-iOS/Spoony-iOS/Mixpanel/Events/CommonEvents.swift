//
//  CommonEvents.swift
//  Spoony-iOS
//
//  Created by 최안용 on 7/4/25.
//

import Mixpanel

struct CommonEvents {
    enum Name {
        static let tabEntered = "tab_entered"
        static let reviewViewed = "review_viewed"
        static let reviewEdited = "review_edited"
        static let profileViewed = "profile_viewed"
        static let followUser = "follow_user"
        static let unfollowUser = "unfollow_user"
        static let followUserFromReview = "follow_user_from_review"
        static let unfollowUserFromReview = "unfollow_user_from_review"
        static let filterApplied = "filter_applied"
    }
    
    enum EntryPoint: String {
        case map
        case mapSearch = "map_searched"
        case explore
        case exploreReviewSearch = "explore_review_searched"
        case userProfile = "user_profile"
        case myPage = "mypage"
        case review
        case followList = "followed_list"
        case followingList = "following_list"
        //TODO: 이거 뭐임?
        case gnbMyPage = "gnb_mypage"
    }
    
    struct TabEnteredProperty: MixpanelProperty {
        let tabName: TabType
        
        var dictionary: [String: MixpanelType] {
            ["tab_name": tabName.rawValue]
        }
    }
    
    struct ReviewViewedProperty: MixpanelProperty {
        let reviewId: Int
        let authorUserId: Int
        let placeId: Int
        let placeName: String
        let category: String
        let menuCount: Int
        let satisfaction: Double
        let reviewLength: Int
        let photoCount: Int
        let hasDisappointment: Bool
        let savedCount: Int
        let isSelfReview: Bool
        let isFollowedUserReview: Bool
        let isSavedReview: Bool
        let entryPoint: EntryPoint
        
        var dictionary: [String: MixpanelType] {
            [
                "review_id": reviewId,
                "author_user_id": authorUserId,
                "place_id": placeId,
                "place_name": placeName,
                "category": category,
                "menu_count": menuCount,
                "satisfaction_score": satisfaction,
                "review_length": reviewLength,
                "photo_count": photoCount,
                "has_disappointment": hasDisappointment,
                "saved_count": savedCount,
                "is_self_review": isSelfReview,
                "is_followed_user_review": isFollowedUserReview,
                "is_saved_review": isSavedReview,
                "entry_point": entryPoint.rawValue
            ]
        }
    }
    
    struct ReviewEditProperty: MixpanelProperty {
        let reviewId: Int
        let authorUserId: Int
        let placeId: Int
        let placeName: String
        let category: String
        let menuCount: Int
        let satisfaction: Double
        let reviewLength: Int
        let photoCount: Int
        let hasDisappointment: Bool
        let savedCount: Int
        let entryPoint: EntryPoint
        
        var dictionary: [String: MixpanelType] {
            [
                "review_id": reviewId,
                "author_user_id": authorUserId,
                "place_id": placeId,
                "place_name": placeName,
                "category": category,
                "menu_count": menuCount,
                "satisfaction": satisfaction,
                "review_length": reviewLength,
                "photo_count": photoCount,
                "has_disappointment": hasDisappointment,
                "saved_count": savedCount,
                "entry_point": entryPoint.rawValue
            ]
        }
    }
    
    struct ProfileViewedProperty: MixpanelProperty {
        let profileUserId: Int
        let isSelfProfile: Bool
        let isFollowingProfileUser: Bool
        let entryPoint: EntryPoint
        
        var dictionary: [String: MixpanelType] {
            [
                "profile_user_id": profileUserId,
                "is_self_profile": isSelfProfile,
                "is_following_profile_user": isFollowingProfileUser,
                "entry_point": entryPoint.rawValue
            ]
        }
    }
    
    struct FollowUserProperty: MixpanelProperty {
        let followedUserId: Int
        let entryPoint: EntryPoint
        
        var dictionary: [String: MixpanelType] {
            [
                "followed_user_id": followedUserId,
                "entry_point": entryPoint.rawValue
            ]
        }
    }
    
    struct UnfollowUserProperty: MixpanelProperty {
        let unfollowedUserId: Int
        let entryPoint: EntryPoint
        
        var dictionary: [String: MixpanelType] {
            [
                "unfollowed_user_id": unfollowedUserId,
                "entry_point": entryPoint.rawValue
            ]
        }
    }
    
    struct ReviewUserFollowInteractionProperty: MixpanelProperty {
        let reviewId: Int
        let authorUserId: Int
        let placeId: Int
        let placeName: String
        let category: String
        let menuCount: Int
        let satisfaction: Double
        let reviewLength: Int
        let photoCount: Int
        let hasDisappointment: Bool
        let savedCount: Int
        let entryPoint: EntryPoint
        
        var dictionary: [String: MixpanelType] {
            [
                "review_id": reviewId,
                "author_user_id": authorUserId,
                "place_id": placeId,
                "place_name": placeName,
                "category": category,
                "menu_count": menuCount,
                "satisfaction_score": satisfaction,
                "review_length": reviewLength,
                "photo_count": photoCount,
                "has_disappointment": hasDisappointment,
                "saved_count": savedCount,
                "entry_point": entryPoint.rawValue
            ]
        }
    }
    
    struct FilterAppliedProperty: MixpanelProperty {
        let pageApplied: String
        let localReviewFilter: Bool
        let regionFilters: [String]
        let categoryFilters: [String]
        let ageGroupFilters: [String]
        
        var dictionary: [String: MixpanelType] {
            [
                "page_applied": pageApplied,
                "local_review_filter": localReviewFilter,
                "region_filters": regionFilters,
                "category_filters": categoryFilters,
                "age_group_filters": ageGroupFilters
            ]
        }
    }
}

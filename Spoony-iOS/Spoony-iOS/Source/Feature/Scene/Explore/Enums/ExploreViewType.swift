//
//  ExploreViewType.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/26/25.
//

import Foundation

enum ExploreViewType: CaseIterable {
    case all
    case following
    
    var title: String {
        switch self {
        case .all:
            "전체"
        case .following:
            "팔로잉"
        }
    }
    
    var emptyDescription: String {
        switch self {
        case .all:
            "아직 발견된 장소가 없어요.\n나만의 리스트를 공유해 볼까요?"
        case .following:
            "아직 팔로우 한 유저가 없어요.\n관심 있는 유저들을 팔로우해보세요."
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .all:
            "등록하러 가기"
        case .following:
            "검색하러 가기"
        }

    }
    
    var lottieImage: String {
        switch self {
        case .all:
            "lottie_empty_explore"
        case .following:
            "lottie_empty_explore"
        }
    }
}

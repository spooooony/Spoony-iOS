//
//  ProfileFeature.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/13/25.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

@Reducer
struct ProfileFeature {
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
        
        var username: String = ""
        var profileImageUrl: String = ""
        var location: String = ""
        var introduction: String = ""
        var spoonCount: Int = 0
        var reviewCount: Int = 0
        var followingCount: Int = 0
        var followerCount: Int = 0
        var isLoading: Bool = false
        var errorMessage: String? = nil
        
        var reviews: [FeedEntity]? = nil
        var isLoadingReviews: Bool = false
        var reviewsErrorMessage: String? = nil
        
        var showDeleteAlert: Bool = false
        var showDeleteConfirm: Bool = false
        var reviewToDeleteId: Int? = nil
    }
    
    enum Action {
        case onAppear
        case userInfoResponse(TaskResult<UserInfoResponse>)
        case fetchUserReviews
        case userReviewsResponse(TaskResult<[FeedEntity]>)
        case routeToReviewsScreen
        case routeToFollowingScreen
        case routeToFollowerScreen
        case routeToEditProfileScreen
        case routeToSettingsScreen
        case routeToAttendanceScreen
        
        case deleteReview(Int)
        case confirmDeleteReview
        case cancelDeleteReview
        case reviewDeleted(TaskResult<Bool>)
        
    }
    
    @Dependency(\.myPageService) var myPageService: MypageServiceProtocol
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .merge(
                    .run { send in
                        await send(.userInfoResponse(
                            TaskResult { try await myPageService.getUserInfo() }
                        ))
                    },
                    .send(.fetchUserReviews)
                )
                
            case let .userInfoResponse(.success(response)):
                state.isLoading = false
                state.username = response.userName
                state.profileImageUrl = response.profileImageUrl
                state.location = response.regionName
                state.introduction = response.introduction
                state.reviewCount = response.reviewCount
                state.followingCount = response.followingCount
                state.followerCount = response.followerCount
                return .none
                
            case let .userInfoResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                print("Error fetching user info: \(error.localizedDescription)")
                return .none
                
            case .fetchUserReviews:
                state.isLoadingReviews = true
                return .run { send in
                    await send(.userReviewsResponse(
                        TaskResult { try await myPageService.getUserReviews() }
                    ))
                }
                
            case let .userReviewsResponse(.success(reviews)):
                state.isLoadingReviews = false
                state.reviews = reviews
                return .none
                
            case let .userReviewsResponse(.failure(error)):
                state.isLoadingReviews = false
                state.reviewsErrorMessage = error.localizedDescription
                print("Error fetching user reviews: \(error.localizedDescription)")
                return .none
                
            case let .deleteReview(postId):
                state.reviewToDeleteId = postId
                state.showDeleteAlert = true
                return .none
                
            case .confirmDeleteReview:
                guard let postId = state.reviewToDeleteId else {
                    return .none
                }
                
                state.isLoadingReviews = true
                return .run { send in
                    await send(.reviewDeleted(
                        TaskResult { try await myPageService.deleteReview(postId: postId) }
                    ))
                }
                
            case .reviewDeleted(.success(true)):
                state.isLoadingReviews = false
                state.showDeleteAlert = false
                
                if let postId = state.reviewToDeleteId, var reviews = state.reviews {
                    reviews.removeAll { $0.postId == postId }
                    state.reviews = reviews
                    state.reviewCount = max(0, state.reviewCount - 1)
                }
                state.reviewToDeleteId = nil
                
                return .none
                
            case .cancelDeleteReview: 
                state.showDeleteAlert = false
                state.reviewToDeleteId = nil
                return .none
                
            case .reviewDeleted(.success(false)):
                // 삭제 실패했지만 API 응답은 성공인 경우
                state.isLoadingReviews = false
                state.showDeleteAlert = false
                state.reviewsErrorMessage = "리뷰 삭제에 실패했습니다. 다시 시도해주세요."
                state.reviewToDeleteId = nil
                return .none
                
            case let .reviewDeleted(.failure(error)):
                state.isLoadingReviews = false
                state.showDeleteAlert = false
                state.reviewsErrorMessage = "리뷰 삭제 실패: \(error.localizedDescription)"
                state.reviewToDeleteId = nil
                return .none
                
            case .routeToReviewsScreen, .routeToFollowingScreen,
                    .routeToFollowerScreen, .routeToEditProfileScreen,
                    .routeToSettingsScreen, .routeToAttendanceScreen:
                return .none
            }
        }
    }
}

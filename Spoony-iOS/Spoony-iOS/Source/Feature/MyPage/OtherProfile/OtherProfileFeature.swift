//
//  OtherProfileFeature.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 5/15/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct OtherProfileFeature {
    @ObservableState
    struct State: Equatable {
        let userId: Int
        var username: String = ""
        var profileImageUrl: String = ""
        var location: String = ""
        var introduction: String = ""
        var reviewCount: Int = 0
        var followingCount: Int = 0
        var followerCount: Int = 0
        var isFollowing: Bool = false
        var isLoading: Bool = false
        var errorMessage: String? = nil
        
        var reviews: [FeedEntity]? = nil
        var isLoadingReviews: Bool = false
        var reviewsErrorMessage: String? = nil
        
        init(userId: Int) {
            self.userId = userId
        }
    }
    
    enum Action {
        case onAppear
        case userInfoResponse(TaskResult<UserInfoResponse>)
        case fetchUserReviews
        case userReviewsResponse(TaskResult<[FeedEntity]>)
        case routeToPreviousScreen
        case followButtonTapped
        case followActionResponse(TaskResult<Void>)
    }
    
    @Dependency(\.myPageService) var myPageService: MypageServiceProtocol
    @Dependency(\.followUseCase) var followUseCase: FollowUseCase
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .merge(
                    .run { [userId = state.userId] send in
                        await send(.userInfoResponse(
                            TaskResult { try await myPageService.getOtherUserInfo(userId: userId) }
                        ))
                    },
                    .send(.fetchUserReviews)
                )
                
            case let .userInfoResponse(.success(response)):
                state.isLoading = false
                state.username = response.userName ?? ""
                state.profileImageUrl = response.profileImageUrl ?? ""
                state.location = response.regionName ?? ""
                state.introduction = response.introduction ?? ""
                state.reviewCount = response.reviewCount
                state.followingCount = response.followingCount
                state.followerCount = response.followerCount
                state.isFollowing = response.isFollowing
                return .none
                
            case let .userInfoResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                print("Error fetching user info: \(error.localizedDescription)")
                return .none
                
            case .fetchUserReviews:
                state.isLoadingReviews = true
                return .run { [userId = state.userId] send in
                    await send(.userReviewsResponse(
                        TaskResult { try await myPageService.getOtherUserReviews(userId: userId) }
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
                
            case .followButtonTapped:
                return .run { [userId = state.userId, isFollowing = state.isFollowing] send in
                    await send(.followActionResponse(
                        TaskResult { try await followUseCase.toggleFollow(userId: userId, isFollowing: isFollowing) }
                    ))
                }
                
            case .followActionResponse(.success):
                state.isFollowing.toggle()
                state.followerCount += state.isFollowing ? 1 : -1
                return .none
                
            case let .followActionResponse(.failure(error)):
                print("Follow action failed: \(error.localizedDescription)")
                return .none
                
            case .routeToPreviousScreen:
                return .none
            }
        }
    }
}

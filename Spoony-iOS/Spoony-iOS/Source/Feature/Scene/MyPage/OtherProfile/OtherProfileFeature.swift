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
        var isBlocked: Bool = false
        var isLoading: Bool = false
        var errorMessage: String? = nil
        
        var reviews: [FeedEntity]? = nil
        var isLoadingReviews: Bool = false
        var reviewsErrorMessage: String? = nil
        
        var isMenuPresented: Bool = false
        var showBlockAlert: Bool = false
        var showUnblockAlert: Bool = false
        
        var toast: Toast? = nil
        
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
        
        case kebabMenuTapped
        case menuItemSelected(String)
        case dismissMenu
        case blockUser
        case unblockUser
        case reportUser
        case confirmBlock
        case confirmUnblock
        case cancelBlock
        case cancelUnblock
        case blockActionResponse(TaskResult<Void>)
        case unblockActionResponse(TaskResult<Void>)
        case routeToReviewDetail(Int)
        
        case hideToast
        case routeToReportScreen(Int)
    }
    
    @Dependency(\.myPageService) var myPageService: MypageServiceProtocol
    @Dependency(\.followUseCase) var followUseCase: FollowUseCase
    @Dependency(\.blockService) var blockService: BlockServiceProtocol
    
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
                state.username = response.userName
                state.profileImageUrl = response.profileImageUrl
                state.location = response.regionName ?? ""
                state.introduction = response.introduction
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
                if state.isBlocked {
                    state.isLoadingReviews = false
                    state.reviews = []
                    return .none
                }
                
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
                if state.isBlocked {
                    return .send(.unblockUser)
                }
                
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
                
            case .kebabMenuTapped:
                state.isMenuPresented.toggle()
                return .none
                
            case let .menuItemSelected(item):
                state.isMenuPresented = false
                if item == "차단하기" {
                    return .send(.blockUser)
                } else if item == "신고하기" {
                    return .send(.reportUser)
                }
                return .none
                
            case .dismissMenu:
                state.isMenuPresented = false
                return .none
                
            case .blockUser:
                state.showBlockAlert = true
                return .none
                
            case .unblockUser:
                state.showUnblockAlert = true
                return .none
                
            case .reportUser:
                return .send(.routeToReportScreen(state.userId))
                
            case .confirmBlock:
                state.showBlockAlert = false
                return .run { [userId = state.userId] send in
                    await send(.blockActionResponse(
                        TaskResult { try await blockService.blockUser(userId: userId) }
                    ))
                }
                
            case .confirmUnblock:
                state.showUnblockAlert = false
                return .run { [userId = state.userId] send in
                    await send(.unblockActionResponse(
                        TaskResult { try await blockService.unblockUser(userId: userId) }
                    ))
                }
                
            case .cancelBlock:
                state.showBlockAlert = false
                return .none
                
            case .cancelUnblock:
                state.showUnblockAlert = false
                return .none
                
            case .blockActionResponse(.success):
                state.isBlocked = true
                state.isFollowing = false
                state.reviews = []
                state.toast = Toast(
                    style: .gray,
                    message: "해당 유저가 차단되었어요.",
                    yOffset: UIScreen.main.bounds.height - 200.adjustedH
                )

                return .run { send in
                    try await Task.sleep(nanoseconds: 2_000_000_000)
                    await send(.hideToast)
                }
                
            case let .blockActionResponse(.failure(error)):
                print("Block action failed: \(error.localizedDescription)")
                return .none
                
            case .unblockActionResponse(.success):
                state.isBlocked = false
                return .send(.fetchUserReviews)
                
            case let .unblockActionResponse(.failure(error)):
                print("Unblock action failed: \(error.localizedDescription)")
                return .none
                
            case .hideToast:
                state.toast = nil
                return .none
                
            case .routeToPreviousScreen, .routeToReviewDetail, .routeToReportScreen:
                return .none
            }
        }
    }
}

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
        var showUnblockAlert: Bool = false
        
        var toast: Toast? = nil
        
        var isAlertPresented: Bool = false
        var alertType: AlertType = .normalButtonTwo
        var alert: Alert = .init(
            title: "테스트",
            confirmButtonTitle: "테스트",
            cancelButtonTitle: "테스트",
            imageString: nil
        )
        
        var selectedReviewFilter: ReviewFilterType = .all
        
        init(userId: Int) {
            self.userId = userId
        }
    }
    
    enum ReviewFilterType: String, CaseIterable {
        case local = "로컬리뷰"
        case all = "전체리뷰"
        
        var isLocalReview: Bool {
            switch self {
            case .local:
                return true
            case .all:
                return false
            }
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case userInfoResponse(TaskResult<UserInfoResponse>)
        case fetchUserReviews
        case userReviewsResponse(TaskResult<[FeedEntity]>)
        case routeToPreviousScreen
        case followButtonTapped
        case followActionResponse(TaskResult<Void>)
        
        case routeToFollowingScreen
        case routeToFollowerScreen
        case routeToFollowScreen(tab: Int)
        
        case kebabMenuTapped
        case menuItemSelected(String)
        case dismissMenu
        case blockUser
        case unblockUser
        case reportUser
        case confirmAction
        case confirmBlock
        case confirmUnblock
        case blockActionResponse(TaskResult<Void>)
        case unblockActionResponse(TaskResult<Void>)
        case routeToReviewDetail(Int)
        
        case hideToast
        case routeToPostReportScreen(Int)
        case routeToUserReportScreen(Int)
        
        case presentAlert(AlertType, Alert)
        
        case selectReviewFilter(ReviewFilterType)
    }
    
    @Dependency(\.myPageService) var myPageService: MypageServiceProtocol
    @Dependency(\.followUseCase) var followUseCase: FollowUseCase
    @Dependency(\.blockService) var blockService: BlockServiceProtocol
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
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
                if state.isBlocked {
                    state.isLoadingReviews = false
                    state.reviews = []
                    return .none
                }
                
                state.isLoadingReviews = true
                let isLocalReview = state.selectedReviewFilter.isLocalReview
                
                return .run { [userId = state.userId, isLocalReview = isLocalReview] send in
                    await send(.userReviewsResponse(
                        TaskResult {
                            try await myPageService.getOtherUserReviews(
                                userId: userId,
                                isLocalReview: isLocalReview
                            )
                        }
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
                
            case let .selectReviewFilter(filterType):
                state.selectedReviewFilter = filterType
                // 필터 변경 시 즉시 API 호출하여 새로운 데이터 로드
                return .send(.fetchUserReviews)
                
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
                
            case .routeToFollowingScreen:
                return .send(.routeToFollowScreen(tab: 1))
                
            case .routeToFollowerScreen:
                return .send(.routeToFollowScreen(tab: 0))
                
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
                return .send(
                    .presentAlert(
                        .normalButtonTwo,
                        Alert(
                            title: "\(state.username)님을\n 차단하시겠습니까?",
                            confirmButtonTitle: "네",
                            cancelButtonTitle: "아니요",
                            imageString: nil
                        )
                    )
                )
                
            case .unblockUser:
                return .send(
                    .presentAlert(
                        .normalButtonTwo,
                        Alert(
                            title: "차단을 해제하시겠습니까?",
                            confirmButtonTitle: "네",
                            cancelButtonTitle: "아니요",
                            imageString: nil
                        )
                    )
                )
                
            case .reportUser:
                return .send(.routeToUserReportScreen(state.userId))
                
            case .confirmAction:
                if state.isBlocked {
                    return .send(.confirmUnblock)
                } else {
                    return .send(.confirmBlock)
                }
                
            case .confirmBlock:
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
                
            case .routeToPreviousScreen, .routeToReviewDetail, .routeToUserReportScreen, .routeToPostReportScreen, .routeToFollowScreen:
                return .none
                
            case let .presentAlert(type, alert):
                state.alertType = type
                state.alert = alert
                state.isAlertPresented = true
                return .none
                
            case .binding:
                return .none
            }
        }
    }
}

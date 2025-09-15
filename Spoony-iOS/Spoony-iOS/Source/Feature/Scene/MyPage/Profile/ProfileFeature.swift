//
//  ProfileFeature.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/13/25.
//

import SwiftUI

import ComposableArchitecture
import Mixpanel
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
        var errorMessage: String?
        
        var reviews: [FeedEntity]?
        var isLoadingReviews: Bool = false
        var reviewsErrorMessage: String?
        
        var showDeleteAlert: Bool = false
        var showDeleteConfirm: Bool = false
        var reviewToDeleteId: Int?
        
        var isLoadingSpoonCount: Bool = false
        var spoonCountErrorMessage: String?
        
        var isRootView: Bool = true
    }
    
    enum Action {
        case onAppear
        case userInfoResponse(TaskResult<UserInfoResponse>)
        case fetchUserReviews
        case userReviewsResponse(TaskResult<[FeedEntity]>)
        case fetchSpoonCount
        case spoonCountResponse(TaskResult<Int>)
                
        case deleteReview(Int)
        case confirmDeleteReview
        case cancelDeleteReview
        case reviewDeleted(TaskResult<Bool>)
                
        case retryFetchUserInfo
        case clearError
        
        case routeToFollowingScreen
        case routeToFollowerScreen
        
        // MARK: - Route Action: 화면 전환 이벤트를 상위 Reducer에 전달 시 사용
        case delegate(Delegate)
        enum Delegate {
            case routeToFollowScreen(tab: Int)
            case routeToSettingsScreen
            case routeToAttendanceScreen
            case routeToEditProfileScreen
            case routeToEditReviewScreen(Int)
            case routeToRegister
            case routeToPreviousScreen
            case routeToReviewDetail(Int)
        }
    }
    
    @Dependency(\.myPageService) var myPageService: MypageServiceProtocol
    @Dependency(\.homeService) var homeService: HomeServiceType
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                state.errorMessage = nil
                
                if KeychainManager.read(key: .accessToken) == nil {
                    state.isLoading = false
                    state.errorMessage = "로그인이 필요합니다."
                    return .none
                }
                
                return .merge(
                    .run { send in
                        await send(.userInfoResponse(
                            TaskResult { try await myPageService.getUserInfo() }
                        ))
                    },
                    .send(.fetchUserReviews),
                    .send(.fetchSpoonCount)
                )
                
            case .retryFetchUserInfo:
                return .send(.onAppear)
                
            case .clearError:
                state.errorMessage = nil
                return .none
                
            case let .userInfoResponse(.success(response)):
                state.isLoading = false
                state.errorMessage = nil
                state.username = response.userName
                state.profileImageUrl = response.profileImageUrl
                state.location = response.regionName ?? "지역 미설정"  
                state.introduction = response.introduction ?? ""
                state.reviewCount = response.reviewCount
                state.followingCount = response.followingCount
                state.followerCount = response.followerCount
                
                let property = CommonEvents.ProfileViewedProperty(
                    profileUserId: response.userId,
                    isSelfProfile: true,
                    isFollowingProfileUser: response.isFollowing,
                    entryPoint: .gnbMyPage
                )
                
                Mixpanel.mainInstance().track(
                    event: CommonEvents.Name.profileViewed,
                    properties: property.dictionary
                )
                
                return .none
                
            case let .userInfoResponse(.failure(error)):
                state.isLoading = false
                
                if let snError = error as? SNError {
                    switch snError {
                    case .networkFail:
                        state.errorMessage = "네트워크 연결을 확인해주세요."
                    case .decodeError:
                        state.errorMessage = "데이터 처리 중 오류가 발생했습니다."
                    case .noData:
                        state.errorMessage = "사용자 정보를 찾을 수 없습니다."
                    case .etc:
                        state.errorMessage = "알 수 없는 오류가 발생했습니다."
                    }
                } else {
                    state.errorMessage = "사용자 정보를 불러오는데 실패했습니다: \(error.localizedDescription)"
                }
                
                print("Error fetching user info: \(error)")
                return .none
                
            case .fetchUserReviews:
                state.isLoadingReviews = true
                state.reviewsErrorMessage = nil
                return .run { send in
                    await send(.userReviewsResponse(
                        TaskResult { try await myPageService.getUserReviews() }
                    ))
                }
                
            case let .userReviewsResponse(.success(reviews)):
                state.isLoadingReviews = false
                state.reviews = reviews
                state.reviewsErrorMessage = nil
                return .none
                
            case let .userReviewsResponse(.failure(error)):
                state.isLoadingReviews = false
                state.reviewsErrorMessage = "리뷰를 불러오는데 실패했습니다."
                print("Error fetching user reviews: \(error)")
                return .none
                
            case .fetchSpoonCount:
                state.isLoadingSpoonCount = true
                state.spoonCountErrorMessage = nil
                return .run { send in
                    await send(.spoonCountResponse(
                        TaskResult { try await homeService.fetchSpoonCount() }
                    ))
                }
                
            case let .spoonCountResponse(.success(count)):
                state.isLoadingSpoonCount = false
                state.spoonCount = count
                state.spoonCountErrorMessage = nil
                return .none
                
            case let .spoonCountResponse(.failure(error)):
                state.isLoadingSpoonCount = false
                state.spoonCount = 0
                state.spoonCountErrorMessage = "스푼 개수를 불러오는데 실패했습니다."
                print("Error fetching spoon count: \(error)")
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
                
                if let postId = state.reviewToDeleteId {
                    if var reviews = state.reviews {
                        reviews.removeAll { $0.postId == postId }
                        state.reviews = reviews
                        state.reviewCount = max(0, state.reviewCount - 1)
                    }
                }
                state.reviewToDeleteId = nil
                
                return .none
                
            case .cancelDeleteReview:
                state.showDeleteAlert = false
                state.reviewToDeleteId = nil
                return .none
                
            case .reviewDeleted(.success(false)):
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

            case .routeToFollowingScreen:
                return .send(.delegate(.routeToFollowScreen(tab: 1)))
                
            case .routeToFollowerScreen:
                return .send(.delegate(.routeToFollowScreen(tab: 0)))
                
            case .delegate:
                return .none
            }
        }
    }
}

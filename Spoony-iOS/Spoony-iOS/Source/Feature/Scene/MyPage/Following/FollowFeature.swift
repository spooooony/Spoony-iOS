//
//  FollowFeature.swift
//  Spoony-iOS
//
//  Created by 이명진 on 5/5/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct FollowFeature {
    
    // MARK: - State
    
    @ObservableState
    struct State: Equatable {
        var followerList: [FollowUserDTO] = []
        var followingList: [FollowUserDTO] = []
        var followerCount: Int = 0
        var followingCount: Int = 0
        var isLoading: Bool = false
        var initialTab: Int = 0
        var targetUserId: Int? = nil 
        
        static let initialState = State()
        
        init(initialTab: Int = 0, targetUserId: Int? = nil) {
            self.initialTab = initialTab
            self.targetUserId = targetUserId
        }
    }
    
    // MARK: - Action
    
    enum Action {
        case onAppear
        case followersResponse(Result<FollowListDTO, Error>)
        case followingsResponse(Result<FollowListDTO, Error>)
        case followButtonTapped(userId: Int, isFollowing: Bool)
        case followActionResponse(Result<Void, Error>)
        case routeToPreviousScreen
        case routeToUserProfileScreen(userId: Int)
        case routeToMyProfileScreen
    }
    
    // MARK: - Dependencies
    
    @Dependency(\.followUseCase) var followUseCase
    
    // MARK: - Body
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .onAppear:
                state.isLoading = true
                return .merge(
                    .run { [targetUserId = state.targetUserId] send in
                        do {
                            let followers: FollowListDTO
                            if let userId = targetUserId {
                                followers = try await followUseCase.getFollowers(userId: userId)
                            } else {
                                followers = try await followUseCase.getMyFollowers()
                            }
                            await send(.followersResponse(.success(followers)))
                        } catch {
                            await send(.followersResponse(.failure(error)))
                        }
                    },
                    .run { [targetUserId = state.targetUserId] send in
                        do {
                            let followings: FollowListDTO
                            if let userId = targetUserId {
                                followings = try await followUseCase.getFollowings(userId: userId)
                            } else {
                                followings = try await followUseCase.getMyFollowings()
                            }
                            await send(.followingsResponse(.success(followings)))
                        } catch {
                            await send(.followingsResponse(.failure(error)))
                        }
                    }
                )
                
            case .followersResponse(let result):
                state.isLoading = false
                switch result {
                case .success(let dto):
                    state.followerList = dto.users
                    state.followerCount = dto.count
                case .failure(let error):
                    print("❌ followers 불러오기 실패 : \(error.localizedDescription)")
                }
                return .none
                
            case .followingsResponse(let result):
                state.isLoading = false
                switch result {
                case .success(let dto):
                    state.followingList = dto.users
                    state.followingCount = dto.count
                case .failure(let error):
                    print("❌ followings 불러오기 실패 : \(error.localizedDescription)")
                }
                return .none
                
            case .followButtonTapped(let userId, let isFollowing):
                return .run { send in
                    do {
                        try await followUseCase.toggleFollow(userId: userId, isFollowing: isFollowing)
                        await send(.followActionResponse(.success(())))
                    } catch {
                        await send(.followActionResponse(.failure(error)))
                    }
                }
                
            case .followActionResponse(let result):
                switch result {
                case .success:
                    return .send(.onAppear) // 데이터 다시 불러오기
                case .failure(let error):
                    print("❌ 팔로우 로직 실패 : \(error.localizedDescription)")
                    return .none
                }
            case .routeToUserProfileScreen:
                return .none
            case .routeToPreviousScreen:
                return .none
            case .routeToMyProfileScreen:
                return .none
            }
        }
    }
}

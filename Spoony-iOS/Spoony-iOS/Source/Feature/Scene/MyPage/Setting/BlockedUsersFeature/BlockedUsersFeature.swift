//
//  BlockedUsersFeature.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/25/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct BlockedUsersFeature {
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
        
        var blockedUsers: [BlockedUserModel] = []
        var isLoading: Bool = false
        var errorMessage: String?
        var processingUserIds: Set<Int> = []
        
        var unblockedUserIds: Set<Int> = []
        var reblockingUserIds: Set<Int> = []
    }
    
    enum Action {
        case onAppear
        case fetchBlockedUsers
        case fetchBlockedUsersResponse(TaskResult<BlockedUsersResponse>)
        case unblockUser(Int)
        case unblockUserResponse(userId: Int, TaskResult<Bool>)
        case reblockUser(Int)
        case reblockUserResponse(userId: Int, TaskResult<Void>)
        case onScrollEvent
        
        // MARK: - Route Action: 화면 전환 이벤트를 상위 Reducer에 전달 시 사용
        case delegate(Delegate)
        enum Delegate {
            case routeToPreviousScreen
        }
    }
    
    @Dependency(\.myPageService) var myPageService
    @Dependency(\.blockService) var blockService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.fetchBlockedUsers)
                
            case .fetchBlockedUsers:
                state.isLoading = true
                state.errorMessage = nil
                
                return .run { send in
                    await send(.fetchBlockedUsersResponse(
                        TaskResult { try await myPageService.getBlockedUsers() }
                    ))
                }
                
            case let .fetchBlockedUsersResponse(.success(response)):
                state.isLoading = false
                state.blockedUsers = response.users
                return .none
                
            case let .fetchBlockedUsersResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                
            case let .unblockUser(userId):
                state.processingUserIds.insert(userId)
                
                return .run { send in
                    await send(.unblockUserResponse(
                        userId: userId,
                        TaskResult { try await myPageService.unblockUser(userId: userId) }
                    ))
                }
                
            case let .unblockUserResponse(userId, .success(isSuccess)):
                state.processingUserIds.remove(userId)
                
                if isSuccess {
                    state.unblockedUserIds.insert(userId)
                }
                
                return .none
                
            case let .unblockUserResponse(userId, .failure):
                state.processingUserIds.remove(userId)
                return .none
                
            case let .reblockUser(userId):
                state.reblockingUserIds.insert(userId)
                
                return .run { send in
                    await send(.reblockUserResponse(
                        userId: userId,
                        TaskResult { try await blockService.blockUser(userId: userId) }
                    ))
                }
                
            case let .reblockUserResponse(userId, .success):
                state.reblockingUserIds.remove(userId)
                
                state.unblockedUserIds.remove(userId)
                
                return .none
                
            case let .reblockUserResponse(userId, .failure):
                state.reblockingUserIds.remove(userId)
                return .none
                
            case .onScrollEvent:
                let userIdsToRemove = state.unblockedUserIds
                if !userIdsToRemove.isEmpty {
                    state.blockedUsers.removeAll { userIdsToRemove.contains($0.userId) }
                    state.unblockedUserIds.removeAll()
                }
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}

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
        var errorMessage: String? = nil
        var processingUserIds: Set<Int> = []
        
        var unblockedUserIds: Set<Int> = []
        var reblockingUserIds: Set<Int> = []
    }
    
    enum Action {
        case routeToPreviousScreen
        case onAppear
        case fetchBlockedUsers
        case fetchBlockedUsersResponse(TaskResult<BlockedUsersResponse>)
        case unblockUser(Int)
        case unblockUserResponse(userId: Int, TaskResult<Bool>)
        case reblockUser(Int) // 재차단 액션 추가
        case reblockUserResponse(userId: Int, TaskResult<Void>)
        case onScrollEvent // 스크롤 이벤트 액션 추가
    }
    
    @Dependency(\.myPageService) var myPageService
    @Dependency(\.blockService) var blockService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .routeToPreviousScreen:
                return .none
                
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
                    // 리스트에서 바로 제거하지 않고, 해제된 사용자로 마킹
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
                
                // 재차단 성공 시 해제된 사용자 목록에서 제거
                state.unblockedUserIds.remove(userId)
                
                return .none
                
            case let .reblockUserResponse(userId, .failure):
                state.reblockingUserIds.remove(userId)
                return .none
                
            case .onScrollEvent:
                // 스크롤 시에만 해제된 사용자들을 리스트에서 실제로 제거
                let userIdsToRemove = state.unblockedUserIds
                if !userIdsToRemove.isEmpty {
                    state.blockedUsers.removeAll { userIdsToRemove.contains($0.userId) }
                    state.unblockedUserIds.removeAll()
                }
                return .none
            }
        }
    }
}

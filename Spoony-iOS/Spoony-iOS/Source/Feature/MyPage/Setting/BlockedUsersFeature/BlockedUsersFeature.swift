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
    }
    
    enum Action {
        case routeToPreviousScreen
        case onAppear
        case fetchBlockedUsers
        case fetchBlockedUsersResponse(TaskResult<BlockedUsersResponse>)
        case unblockUser(Int)
        case unblockUserResponse(userId: Int, TaskResult<Bool>)
    }
    
    @Dependency(\.myPageService) var myPageService
    
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
                    state.blockedUsers.removeAll { $0.userId == userId }
                }
                
                return .none
                
            case let .unblockUserResponse(userId, .failure):
                state.processingUserIds.remove(userId)
                return .none
            }
        }
    }
}

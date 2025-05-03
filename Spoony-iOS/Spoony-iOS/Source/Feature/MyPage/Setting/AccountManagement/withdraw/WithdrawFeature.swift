//
//  WithdrawFeature.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 5/3/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct WithdrawFeature {
    enum WithdrawAlert: Equatable {
        case confirmWithdraw
    }
    
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
        
        var isAgreed: Bool = false
        var withdrawAlert: WithdrawAlert? = nil
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case routeToPreviousScreen
        case toggleAgreement
        case withdrawButtonTapped
        case confirmWithdraw
        case cancelWithdraw
        case performWithdraw
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .routeToPreviousScreen:
                return .none
                
            case .toggleAgreement:
                state.isAgreed.toggle()
                return .none
                
            case .withdrawButtonTapped:
                state.withdrawAlert = .confirmWithdraw
                return .none
                
            case .confirmWithdraw:
                state.withdrawAlert = nil
                return .send(.performWithdraw)
                
            case .cancelWithdraw:
                state.withdrawAlert = nil
                return .none
                
            case .performWithdraw:
                return .none
            }
        }
    }
}

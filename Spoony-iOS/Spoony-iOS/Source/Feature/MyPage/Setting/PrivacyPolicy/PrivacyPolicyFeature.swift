//
//  PrivacyPolicyFeature.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/25/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct PrivacyPolicyFeature {
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
    }
    
    enum Action {
        case routeToPreviousScreen
    }
    
    var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .routeToPreviousScreen:
                return .none
            }
        }
    }
}

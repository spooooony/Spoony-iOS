//
//  AttendanceFeature.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/17/25.
//

import Foundation

import ComposableArchitecture

@Reducer
struct AttendanceFeature {
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
            default:
                return .none
            }
        }
    }
}

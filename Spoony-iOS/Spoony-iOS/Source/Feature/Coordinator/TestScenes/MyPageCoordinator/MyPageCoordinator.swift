//
//  MyPageCoordinator.swift
//  Spoony-iOS
//
//  Created by 최안용 on 4/4/25.
//

import ComposableArchitecture
import SwiftUI

// MARK: - MyPageCoordinator
@Reducer
struct MyPageCoordinator {
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
    }
    
    enum Action {}
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
        }
    }
}

struct MyPageView: View {
    let store: StoreOf<MyPageCoordinator>
    
    var body: some View {
        Text("My Page View")
    }
}

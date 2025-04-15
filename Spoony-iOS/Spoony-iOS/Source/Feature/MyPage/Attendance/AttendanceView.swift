//
//  AttendanceView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/13/25.
//

import SwiftUI

import ComposableArchitecture
import TCACoordinators

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
        Reduce { state, action in
            switch action {
            case .routeToPreviousScreen:
                return .none
            }
        }
    }
}

struct AttendanceView: View {
    @Bindable private var store: StoreOf<AttendanceFeature>
    
    init(store: StoreOf<AttendanceFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            CustomNavigationBar(
                style: .detail,
                title: "출석체크",
                onBackTapped: {
                    store.send(.routeToPreviousScreen)
                }
            )
            
            Spacer()
            
            Text("Attendance View")
                .font(.largeTitle)
            
            Spacer()
        }
    }
}

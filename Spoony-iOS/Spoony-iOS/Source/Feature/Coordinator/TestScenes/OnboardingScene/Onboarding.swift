//
//  Onboarding.swift
//  Spoony-iOS
//
//  Created by 최안용 on 4/3/25.
//


import SwiftUI
import ComposableArchitecture

@Reducer
struct Onboarding {
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
    }
    
    enum Action {
        case routToTabCoordinatorScreen
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            .none
        }
    }
}

struct OnboardingView: View {
    let store: StoreOf<Onboarding>
    
    var body: some View {
        VStack {
            Text("Onboarding Screen")
            Button("Go to Tab Coordinator") {
                store.send(.routToTabCoordinatorScreen)
            }
        }
    }
}
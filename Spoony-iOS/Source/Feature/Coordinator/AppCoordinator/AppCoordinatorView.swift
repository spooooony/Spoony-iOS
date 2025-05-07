//
//  AppCoordinatorView.swift
//  Spoony-iOS
//
//  Created by 최안용 on 4/1/25.
//

import SwiftUI

import ComposableArchitecture
import TCACoordinators

struct AppCoordinatorView: View {
    private let store: StoreOf<AppCoordinator>
    
    init(store: StoreOf<AppCoordinator>) {
        self.store = store
    }
    
    var body: some View {
        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            switch screen.case {
            case let .auth(store):
                LoginView(store: store)
                
            case let .termsOfService(store):
                AgreeView(store: store)
                
            case let .onboarding(store):
                OnboardingView(store: store)
                
            case let .tabCoordinator(store):
                TabCoordinatorView(store: store)
            }
        }
    }
}

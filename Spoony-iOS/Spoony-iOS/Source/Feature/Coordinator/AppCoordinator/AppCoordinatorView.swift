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
    @StateObject private var authManager = AuthenticationManager.shared
    
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
                
            case let .tabRootCoordinator(store):
                TabRootCoordinatorView(store: store)
            }
        }
        .toastView(
            toast: Binding(
                get: { store.toast },
                set: { store.send(.updateToast($0)) }
            )
        )
        .onChange(of: authManager.authenticationState) {
            if authManager.authenticationState == .unAuthenticated {
                store.send(.routeToLoginScreen)
            }
        }
    }
}

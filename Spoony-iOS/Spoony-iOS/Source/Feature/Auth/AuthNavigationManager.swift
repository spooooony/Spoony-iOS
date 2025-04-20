//
//  AuthNavigationManager.swift
//  Spoony-iOS
//
//  Created by 최주리 on 3/25/25.
//

import SwiftUI

import ComposableArchitecture

final class AuthNavigationManager: ObservableObject {
    @Published var path: [AuthViewType] = []
    
    @ViewBuilder
    func build(_ view: AuthViewType) -> some View {
        switch view {
        case .agreeView:
            AgreeView(store: StoreOf<AgreeFeature>(initialState: AgreeFeature.State(), reducer: {
                AgreeFeature()
            }))
        case .onboardingView:
            EmptyView()
        case .completeOnboardingView:
            EmptyView()
        }
    }
    
    func push(_ view: AuthViewType) {
        path.append(view)
    }
}

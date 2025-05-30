//
//  TabRootCoordinatorView.swift
//  Spoony-iOS
//
//  Created by 최안용 on 5/27/25.
//

import SwiftUI

import ComposableArchitecture
import TCACoordinators

struct TabRootCoordinatorView: View {
    private let store: StoreOf<TabRootCoordinator>
    
    init(store: StoreOf<TabRootCoordinator>) {
        self.store = store
    }
    
    var body: some View {
        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            switch screen.case {
            case let .tab(store):
                TabCoordinatorView(store: store)
                
            case let .registerAndEdit(store: store):
                Register(store: store)
                    .toolbar(.hidden, for: .navigationBar)
                
            case let .settings(store):
                SettingsView(store: store)
                
            case let .editProfile(store):
                EditProfileView(store: store)
                
            case let .attendance(store):
                AttendanceView(store: store)
                    .navigationBarBackButtonHidden()
                    .toolbar(.hidden, for: .tabBar)
                
            case let .accountManagement(store):
                AccountManagementView(store: store)
                    .navigationBarBackButtonHidden()
                
            case let .blockedUsers(store):
                BlockedUsersView(store: store)
                    .navigationBarBackButtonHidden()
                
            case let .withdraw(store):
                WithdrawView(store: store)
                    .navigationBarBackButtonHidden()
                
            case let .detail(store):
                PostView(postId: store.postId, store: store)
                
            case let .report(store):
                Report(postId: store.postId, userId: nil, store: store)
            }
        }
        .toastView(
            toast: Binding(
                get: { store.toast },
                set: { store.send(.updateToast($0)) }
            )
        )
        .popup(popup: Binding(
                get: { store.popup },
                set: { store.send(.updatePopup($0))}
            )) { popup in
                store.send(.popupAction(popup))
        }
    }
}

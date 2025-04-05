//
//  TabCoordinatorView.swift
//  Spoony-iOS
//
//  Created by 최안용 on 4/1/25.
//

import SwiftUI

import ComposableArchitecture

struct TabCoordinatorView: View {
    @Bindable private var store: StoreOf<TabCoordinator>
        
    init(store: StoreOf<TabCoordinator>) {
        self.store = store
        setTabBarAppearance()
    }
    
    var body: some View {
        TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
            ForEach(TabType.allCases, id: \.self) { tab in
                Group {
                    switch tab {
                    case .map:
                        MapView(store: store.scope(state: \.map, action: \.map))
                    case .explore:
                        ExploreView(store: store.scope(state: \.explore, action: \.explore))
                    case .register:
                        Register(store: store.scope(state: \.register, action: \.register))
                    case .myPage:
                        MyPageView(store: store.scope(state: \.myPage, action: \.myPage))
                    }
                }
                .tabItem {
                    Label(
                        tab.title,
                        image: tab.imageName(selected: store.state.selectedTab == tab)
                    )
                }
                .tag(tab)
            }
        }
        .toastView(toast: $store.toast)
        .popup(popup: $store.popup) { popup in
            store.send(.popupAction(popup))
        }
    }
}

extension TabCoordinatorView {
    private func setTabBarAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        
        tabBarAppearance.backgroundColor = .white
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.main400,
            .font: UIFont.caption2b
        ]
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.gray400,
            .font: UIFont.caption2b
        ]
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}

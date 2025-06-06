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
                        MapCoordinatorView(store: store.scope(state: \.map, action: \.map))
                    case .explore:
                        ExploreCoordinatorView(store: store.scope(state: \.explore, action: \.explore))
                    case .register:
                        Color.clear
                    case .myPage:
                        MyPageCoordinatorView(store: store.scope(state: \.myPage, action: \.myPage))
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

//
//  SpoonyTabView.swift
//  SpoonMe
//
//  Created by 최주리 on 1/7/25.
//

import SwiftUI

struct SpoonyTabView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    init() {
        setTabBarAppearance()
    }
    
    var body: some View {
        
        TabView(selection: Binding(get: {
            navigationManager.state.selectedTab
        }, set: { newValue in
            navigationManager.dispatch(.changeTab(newValue))
        })) {
            ForEach(TabType.allCases, id: \.self) { tab in
                Group {
                    switch tab {
                    case .map:
                        NavigationStack(path: Binding(get: {
                            navigationManager.state.mapPath
                        }, set: { newValue in
                            navigationManager.dispatch(.changePath(newValue, .map))
                        })) {
                            Home()
                                .navigationDestination(for: ViewType.self) { view in
                                    navigationManager.build(view)
                                        .navigationBarBackButtonHidden()
                                }
                        }
                    case .explore:
                        NavigationStack(path: Binding(get: {
                            navigationManager.state.explorePath
                        }, set: { newValue in
                            navigationManager.dispatch(.changePath(newValue, .explore))
                        })) {
                            Explore(store: .init(navigationManager: navigationManager))
                                .navigationDestination(for: ViewType.self) { view in
                                    navigationManager.build(view)
                                        .navigationBarBackButtonHidden()
                                }
                        }
                    case .register:
                        NavigationStack(path: Binding(get: {
                            navigationManager.state.registerPath
                        }, set: { newValue in
                            navigationManager.dispatch(.changePath(newValue, .register))
                        })) {
                            Register(
                                store: .init(navigationManager: navigationManager)
                            )
                            .navigationDestination(for: ViewType.self) { view in
                                navigationManager.build(view)
                                    .navigationBarBackButtonHidden()
                            }
                        }
                    }
                }
                .tabItem {
                    Label(
                        tab.title,
                        image: tab.imageName(selected: navigationManager.state.selectedTab == tab)
                    )
                }
                .tag(tab)
            }
        }
    }
}

extension SpoonyTabView {
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

#Preview {
    SpoonyTabView()
        .environmentObject(NavigationManager())
}

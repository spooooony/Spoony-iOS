//
//  EditProfileView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/13/25.
//

import SwiftUI

import ComposableArchitecture
import TCACoordinators

struct EditProfileView: View {
    @Bindable private var store: StoreOf<EditProfileFeature>
    
    init(store: StoreOf<EditProfileFeature>) {
        self.store = store
        setTabBarAppearance()

    }
    
    var body: some View {
        VStack {
            CustomNavigationBar(
                style: .detail,
                searchText: .constant(""),
                onBackTapped: {
                    store.send(.routeToPreviousScreen)
                }
            )
            
            Spacer()
            
            Text("Edit Profile View")
                .font(.largeTitle)
            
            Spacer()
        }
        .navigationBarHidden(true)
    }
}

extension EditProfileView {
    func setTabBarAppearance() {
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

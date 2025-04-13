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
    }
}

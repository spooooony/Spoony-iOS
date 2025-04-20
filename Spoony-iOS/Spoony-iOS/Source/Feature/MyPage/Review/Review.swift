//
//  Review.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/13/25.
//

import SwiftUI

import ComposableArchitecture
import TCACoordinators

struct ReviewsView: View {
    @Bindable private var store: StoreOf<ReviewsFeature>
    
    init(store: StoreOf<ReviewsFeature>) {
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
            
            Text("Reviews View")
                .font(.largeTitle)
            
            Spacer()
        }
        .navigationBarHidden(true)
    }
}

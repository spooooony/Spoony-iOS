//
//  InquiryView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/25/25.
//

import SwiftUI
import ComposableArchitecture

struct InquiryView: View {
    @Bindable private var store: StoreOf<InquiryFeature>
    
    init(store: StoreOf<InquiryFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            CustomNavigationBar(
                style: .detail,
                title: "1:1 문의",
                searchText: .constant(""),
                onBackTapped: {
                    store.send(.routeToPreviousScreen)
                }
            )
        }
    }
}

#Preview {
    InquiryView(store: Store(initialState: .initialState, reducer: {
        InquiryFeature()
    }))
}

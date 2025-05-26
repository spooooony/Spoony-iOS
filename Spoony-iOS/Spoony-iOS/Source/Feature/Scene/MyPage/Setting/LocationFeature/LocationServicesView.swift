//
//  LocationServicesView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/25/25.
//

import SwiftUI
import ComposableArchitecture

struct LocationServicesView: View {
    @Bindable private var store: StoreOf<LocationServicesFeature>
    
    init(store: StoreOf<LocationServicesFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            CustomNavigationBar(
                style: .detail,
                title: "위치기반서비스 이용약관",
                searchText: .constant(""),
                onBackTapped: {
                    store.send(.routeToPreviousScreen)
                }
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("위치기반서비스 이용약관")
                        .font(.title3b)
                        .padding(.top, 20)
                    
                    Text("이 약관은 스푸니의 위치기반서비스 이용에 관한 내용을 담고 있습니다.")
                        .font(.body2m)
                        .foregroundStyle(.gray700)
                        .padding(.bottom, 20)
                    
                    Text("위치기반서비스 이용약관 내용이 여기에 표시됩니다.")
                        .font(.body2m)
                        .foregroundStyle(.gray700)
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
    }
}

#Preview {
    LocationServicesView(store: Store(initialState: .initialState, reducer: {
        LocationServicesFeature()
    }))
}

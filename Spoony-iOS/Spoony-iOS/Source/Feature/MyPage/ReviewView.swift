//
//  ReviewView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/11/25.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import TCACoordinators


@Reducer
struct ReviewsFeature {
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
        var reviews: [ReviewItem] = []
    }
    
    enum Action {
        case routeToPreviousScreen
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .routeToPreviousScreen:
                return .none
            }
        }
    }
}

// ReviewsView.swift
struct ReviewsView: View {
    @Bindable private var store: StoreOf<ReviewsFeature>
    
    init(store: StoreOf<ReviewsFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            // 커스텀 네비게이션 바 사용
            CustomNavigationBar(
                style: .detail,
                title: "내 리뷰",
                onBackTapped: {
                    store.send(.routeToPreviousScreen)
                }
            )
            
            if store.reviews.isEmpty {
                // 리뷰가 없는 경우
                VStack(spacing: 16) {
                    Spacer()
                    
                    Image("icReviewEmpty") // 이미지 리소스 필요
                    
                    Text("아직 등록한 리뷰가 없어요.")
                        .customFont(.body1m)
                        .foregroundStyle(.gray500)
                    
                    Spacer()
                }
            } else {
                // 리뷰 목록 표시
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(store.reviews, id: \.id) { review in
                            // 리뷰 아이템 표시
                            Text("리뷰 아이템")
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

// 리뷰 아이템 구조체
struct ReviewItem: Equatable, Identifiable {
    var id: Int
    var title: String
    var content: String
    var location: String
    var date: Date
    // 추가 속성들
}

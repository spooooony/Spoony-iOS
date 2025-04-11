//
//  ProfileFeature.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/11/25.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import TCACoordinators

@Reducer
struct ProfileFeature {
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
        var username: String = "서울 마포구 스푸"
        var location: String = "크리스탈에메랄드수정"
        var spoonCount: Int = 99
        var reviewCount: Int = 0
        var followingCount: Int = 0
        var followerCount: Int = 0
    }
    
    enum Action {
        case routeToReviewsScreen
        case routeToFollowingScreen
        case routeToFollowerScreen
        case routeToEditProfileScreen
        case routeToSettingsScreen
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .routeToReviewsScreen, .routeToFollowingScreen,
                 .routeToFollowerScreen, .routeToEditProfileScreen,
                 .routeToSettingsScreen:
                return .none
            }
        }
    }
}

// ProfileView.swift
struct ProfileView: View {
    @Bindable private var store: StoreOf<ProfileFeature>
    
    init(store: StoreOf<ProfileFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                style: .settingContent,
                spoonCount: store.spoonCount,
                tappedAction: {
                    store.send(.routeToSettingsScreen)
                }
            )
            
            // 프로필 정보 영역
            VStack(spacing: 24) {
                // 프로필 이미지와 정보
                HStack(spacing: 16) {
                    Circle()
                        .fill(Color.gray200)
                        .frame(width: 72, height: 72)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(store.username)
                                .customFont(.title2b)
                                .foregroundStyle(.spoonBlack)
                            
                            // 스푼 카운트 칩
                            HStack(spacing: 4) {
                                Text("\(store.spoonCount)")
                                    .customFont(.caption1m)
                                    .foregroundStyle(.main500)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.main0)
                            )
                        }
                        
                        Text(store.location)
                            .customFont(.body2m)
                            .foregroundStyle(.gray600)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                // 리뷰, 팔로잉, 팔로워 카운트
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Text("\(store.reviewCount)")
                            .customFont(.title1b)
                            .foregroundStyle(.spoonBlack)
                        Text("리뷰")
                            .customFont(.body2m)
                            .foregroundStyle(.gray600)
                    }
                    .onTapGesture {
                        store.send(.routeToReviewsScreen)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Text("\(store.followingCount)")
                            .customFont(.title1b)
                            .foregroundStyle(.spoonBlack)
                        Text("팔로잉")
                            .customFont(.body2m)
                            .foregroundStyle(.gray600)
                    }
                    .onTapGesture {
                        store.send(.routeToFollowingScreen)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Text("\(store.followerCount)")
                            .customFont(.title1b)
                            .foregroundStyle(.spoonBlack)
                        Text("팔로워")
                            .customFont(.body2m)
                            .foregroundStyle(.gray600)
                    }
                    .onTapGesture {
                        store.send(.routeToFollowerScreen)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 16)
                
                // 프로필 수정 버튼
                Button(action: {
                    store.send(.routeToEditProfileScreen)
                }) {
                    Text("프로필 수정")
                        .customFont(.body1sb)
                        .foregroundStyle(.gray600)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray200, lineWidth: 1)
                        )
                }
                .padding(.horizontal, 20)
            }
            
            // 리뷰 목록 영역
            VStack(alignment: .leading, spacing: 16) {
                Text("리뷰")
                    .customFont(.title1b)
                    .foregroundStyle(.spoonBlack)
                    .padding(.top, 32)
                    .padding(.horizontal, 20)
                
                if store.reviewCount == 0 {
                    // 리뷰가 없는 경우 표시할 뷰
                    VStack(spacing: 16) {
                        Image("icReviewEmpty") // 이미지 리소스 필요
                        
                        Text("아직 등록한 리뷰가 없어요.")
                            .customFont(.body1m)
                            .foregroundStyle(.gray500)
                        
                        Text("나만의 찐맛집을 공유해 보세요!")
                            .customFont(.body2m)
                            .foregroundStyle(.gray500)
                        
                        Button(action: {
                            // 등록 탭으로 이동 로직
                        }) {
                            Text("등록하러 가기")
                                .customFont(.body1sb)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.main400)
                                )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                    }
                    .padding(.top, 40)
                } else {
                    // 리뷰 목록 (리뷰가 있는 경우)
                    // 여기에 리뷰 리스트 구현
                    Text("리뷰 리스트가 표시됩니다")
                        .customFont(.body1m)
                        .foregroundStyle(.gray500)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 40)
                }
            }
            
            Spacer()
        }
    }
}

#Preview {
    ProfileView(
        store: Store(initialState: ProfileFeature.State()) {
            ProfileFeature()
        }
    )
}

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
        var username: String = "서울 마포구 스푼"
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
            .padding(.bottom, 24)
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 24) {
                    // 프로필 사진 대체예정
                    Circle()
                        .fill(Color.gray200)
                        .frame(width: 85.adjusted, height: 85.adjustedH)
                    Spacer()
                    
                    HStack(spacing: 54) {
                        VStack(spacing: 8) {
                            Text("리뷰")
                                .customFont(.caption1b)
                                .foregroundStyle(.gray400)
                            Text("\(store.reviewCount)")
                                .customFont(.body1sb)
                                .foregroundStyle(.spoonBlack)
                        }
                        .onTapGesture {
                            store.send(.routeToReviewsScreen)
                        }
                        
                        VStack(spacing: 8) {
                            Text("팔로워")
                                .customFont(.caption1b)
                                .foregroundStyle(.gray400)
                            Text("\(store.followerCount)")
                                .customFont(.body1sb)
                                .foregroundStyle(.spoonBlack)
                        }
                        .onTapGesture {
                            store.send(.routeToFollowerScreen)
                        }
                        
                        VStack(spacing: 8) {
                            Text("팔로잉")
                                .customFont(.caption1b)
                                .foregroundStyle(.gray400)
                            Text("\(store.followerCount)")
                                .customFont(.body1sb)
                                .foregroundStyle(.spoonBlack)
                        }
                        .onTapGesture {
                            store.send(.routeToFollowingScreen)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                
                // 사용자 정보 영역
                HStack(alignment: .center, spacing: 0) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(store.username)
                            .customFont(.body2sb)
                            .foregroundStyle(.gray600)
                            .padding(.bottom, 4)
                        
                        Text("크리스탈에메랄드수정")
                            .customFont(.title2b)
                            .foregroundStyle(.spoonBlack)
                            .padding(.bottom, 8)
                        
                        Text(store.location)
                            .customFont(.caption1m)
                            .foregroundStyle(.gray600)
                    }
                    
                    Spacer()
                    
                    //디자인시스템에 없음핑
                    Button(action: {
                        store.send(.routeToEditProfileScreen)
                    }) {
                        Text("프로필 수정")
                            .customFont(.body2sb)
                            .foregroundStyle(.white)
                            .frame(width: 103.adjusted)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.main400)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 27)
            }
            
            Divider()
                .frame(height: 2)
                .background(Color.gray0)
                .padding(0)
           
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("리뷰")
                        .customFont(.title2b)
                        .foregroundStyle(.spoonBlack)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                
                if store.reviewCount == 0 {
                    VStack(spacing: 16) {
                        Image(.imageGoToList)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .padding(.top, 30)
                        
                        Text("아직 등록한 리뷰가 없어요.\n나만의 찐맛집을 공유해 보세요!")
                            .customFont(.body1m)
                            .foregroundStyle(.gray500)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)

                        SpoonyButton(
                            style: .primary,
                            size: .xsmall,
                            title: "등록하러가기",
                            isIcon: false,
                            disabled: .constant(false)
                        ) {
                            //TODO: 등록 탭으로 이동 로직
                        }
                        .padding(.horizontal, 20)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                } else {
                    // 리뷰가 있는 경우 리뷰 목록 표시
                }
            }
            .padding(.bottom, 40)
            .padding(.bottom, 40)
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

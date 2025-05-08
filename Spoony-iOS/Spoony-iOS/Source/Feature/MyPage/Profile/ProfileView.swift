//
//  ProfileView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/11/25.
//

import SwiftUI

import ComposableArchitecture
import TCACoordinators

struct ProfileView: View {
    @Bindable private var store: StoreOf<ProfileFeature>
    
    init(store: StoreOf<ProfileFeature>) {
        self.store = store
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                navigationBar
                
                if store.isLoading {
                    loadingView
                } else if store.errorMessage != nil {
                    errorView
                } else {
                    profileContentView
                }
            }
            
            if store.showDeleteAlert {
                CustomAlertView(
                    title: "정말로 리뷰를 삭제할까요?",
                    cancelTitle: "아니요",
                    confirmTitle: "네",
                    cancelAction: {
                        store.send(.cancelDeleteReview)
                    },
                    confirmAction: {
                        store.send(.confirmDeleteReview)
                    }
                )
            }
        }
        .toolbar(store.showDeleteAlert ? .hidden : .visible, for: .tabBar)
        .task {
            store.send(.onAppear)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    private var navigationBar: some View {
        CustomNavigationBar(
            style: .settingContent,
            spoonCount: store.spoonCount,
            spoonTapped: {
                store.send(.routeToAttendanceScreen)
            },
            tappedAction: {
                store.send(.routeToSettingsScreen)
            }
        )
        .padding(.bottom, 24)
    }
    
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Spacer()
        }
    }
    
    private var errorView: some View {
        VStack {
            Spacer()
            Text("정보를 불러오는데 실패했습니다.")
                .customFont(.body1m)
                .foregroundStyle(.gray600)
            Text(store.errorMessage ?? "")
                .customFont(.caption1m)
                .foregroundStyle(.gray400)
                .padding(.top, 8)
            Button("다시 시도") {
                store.send(.onAppear)
            }
            .padding(.top, 16)
            Spacer()
        }
    }
    
    private var profileContentView: some View {
        VStack(spacing: 0) {
            profileSection
            
            Divider()
                .frame(height: 2)
                .background(Color.gray0)
                .padding(0)
            
            reviewsSection
            Spacer()
        }
    }
    
    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            profileHeader
            profileInfo
        }
    }
    
    private var profileHeader: some View {
        HStack(alignment: .center, spacing: 24) {
            AsyncImage(url: URL(string: store.profileImageUrl)) { phase in
                if case .success(let image) = phase {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 85.adjusted, height: 85.adjustedH)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray200)
                        .frame(width: 85.adjusted, height: 85.adjustedH)
                }
            }
            
            Spacer()
            
            statsCounters
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }
    
    private var statsCounters: some View {
        HStack(spacing: 54) {
            statCounter(title: "리뷰", count: store.reviewCount) {
                // 리뷰 누르면 이동하는 곳 없지 않나요?
//                store.send(.routeToReviewsScreen)
            }
            
            statCounter(title: "팔로워", count: store.followerCount) {
                store.send(.routeToFollowerScreen)
            }
            
            statCounter(title: "팔로잉", count: store.followingCount) {
                store.send(.routeToFollowingScreen)
            }
        }
    }
    
    private func statCounter(title: String, count: Int, action: @escaping () -> Void) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .customFont(.caption1b)
                .foregroundStyle(.gray400)
            Text("\(count)")
                .customFont(.body1sb)
                .foregroundStyle(.spoonBlack)
        }
        .onTapGesture(perform: action)
    }
    
    private var profileInfo: some View {
        HStack(alignment: .center, spacing: 0) {
            userInfoSection
            
            Spacer()
            
            editProfileButton
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 27)
    }
    
    private var userInfoSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("서울 \(store.location) 스푼")
                .customFont(.body2sb)
                .foregroundStyle(.gray600)
                .padding(.bottom, 4)
            
            Text(store.username)
                .customFont(.title3sb)
                .foregroundStyle(.spoonBlack)
                .padding(.bottom, 8)
            
            if !store.introduction.isEmpty {
                Text(store.introduction)
                    .customFont(.caption1m)
                    .foregroundStyle(.gray600)
                    .lineLimit(2)
            }
        }
    }
    
    private var editProfileButton: some View {
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
    
    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            reviewsHeader
            
            if store.isLoadingReviews {
                reviewsLoadingView
            } else if let error = store.reviewsErrorMessage {
                reviewsErrorView(error)
            } else if let reviews = store.reviews, !reviews.isEmpty {
                reviewListView(reviews)
            } else {
                emptyReviewsView
            }
        }
    }
    
    private var reviewsHeader: some View {
        HStack {
            Text("리뷰")
                .customFont(.body1b)
                .foregroundStyle(.spoonBlack)
            Text("\(store.reviewCount)개")
                .customFont(.body2m)
                .foregroundStyle(.gray400)
        }
        .padding(.horizontal, 20)
        .padding(.top, 19)
    }
    
    private var reviewsLoadingView: some View {
        VStack {
            ProgressView()
                .padding(.top, 30)
                .frame(maxWidth: .infinity)
        }
    }
    
    private func reviewsErrorView(_ error: String) -> some View {
        VStack {
            Text("리뷰를 불러오는데 실패했습니다.")
                .customFont(.body2m)
                .foregroundStyle(.gray600)
                .multilineTextAlignment(.center)
                .padding(.top, 30)
                .frame(maxWidth: .infinity)
        }
    }
    
    private func reviewListView(_ reviews: [FeedEntity]) -> some View {
        ZStack {
            // 리뷰 목록
            ScrollView {
                LazyVStack(spacing: 18) {
                    ForEach(reviews) { review in
                        ExploreCell(
                            feed: review,
                            onDelete: { postId in
                                store.send(.deleteReview(postId))
                            },
                            onEdit: { feed in
                                // 수정 기능
                                store.send(.routeToEditReviewScreen(feed.postId))
                            }
                        )
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.top, 16)
            }
        }
    }
    
    private var emptyReviewsView: some View {
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
    }
}

#Preview {
    ProfileView(
        store: Store(initialState: ProfileFeature.State()) {
            ProfileFeature()
        }
    )
}

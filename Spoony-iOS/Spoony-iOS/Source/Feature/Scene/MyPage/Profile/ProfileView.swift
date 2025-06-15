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
                
                ScrollView {
                    VStack(spacing: 0) {
                        if store.isLoading {
                            loadingView
                        } else {
                            profileContentView
                        }
                    }
                    .padding(.bottom, 30)
                }
                .refreshable {
                    store.send(.onAppear)
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
                .zIndex(10)
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
        .padding(.bottom, 3)
    }
    
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Text("프로필 정보를 불러오는 중...")
                .customFont(.body2m)
                .foregroundStyle(.gray600)
                .padding(.top, 16)
            Spacer()
        }
        .frame(height: 300.adjustedH)
    }
    
    private func errorBanner(error: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text("일부 정보를 불러오지 못했습니다")
                .customFont(.caption1m)
                .foregroundColor(.orange)
            Spacer()
            Button("다시 시도") {
                store.send(.retryFetchUserInfo)
            }
            .customFont(.caption1m)
            .foregroundColor(.main400)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    private var profileContentView: some View {
        VStack(spacing: 0) {
            if let error = store.errorMessage {
                errorBanner(error: error)
            }
            
            ProfileHeaderView(store: store)
            
            Divider()
                .frame(height: 2)
                .background(Color.gray0)
            
            ProfileReviewsView(store: store)
        }
    }
}

// MARK: - Profile Header View
struct ProfileHeaderView: View {
    @Bindable var store: StoreOf<ProfileFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            profileHeader
            profileInfo
        }
    }
    
    private var profileHeader: some View {
        HStack(alignment: .center, spacing: 39) {
            profileImage
            statsCounters
        }
        .padding(.leading, 20.adjusted)
        .padding(.trailing, 44.adjusted)
        .padding(.bottom, 24.adjustedH)
    }
    
    private var profileImage: some View {
        Group {
            if !store.profileImageUrl.isEmpty {
                AsyncImage(url: URL(string: store.profileImageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        defaultProfileImage
                    case .empty:
                        ProgressView()
                            .frame(width: 85.adjusted, height: 85.adjustedH)
                    @unknown default:
                        defaultProfileImage
                    }
                }
                .frame(width: 85.adjusted, height: 85.adjustedH)
                .clipShape(Circle())
            } else {
                defaultProfileImage
            }
        }
    }
    
    private var defaultProfileImage: some View {
        Circle()
            .fill(Color.gray200)
            .frame(width: 85.adjusted, height: 85.adjustedH)
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: 35))
                    .foregroundColor(.gray400)
            )
    }
    
    private var statsCounters: some View {
        HStack(spacing: 54) {
            statCounter(title: "리뷰", count: store.reviewCount) {
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
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
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
            let locationText = store.location.isEmpty || store.location == "지역 미설정" ?
                (store.errorMessage != nil ? "지역 정보 없음" : "") : "\(store.location) 스푼"
            
            if !locationText.isEmpty {
                Text(locationText)
                    .customFont(.body2sb)
                    .foregroundStyle(.gray600)
                    .padding(.bottom, 4)
            }
            
            let userName = store.username.isEmpty ?
                (store.errorMessage != nil ? "사용자" : "이름 없음") : store.username
                
            Text(userName)
                .customFont(.title3sb)
                .foregroundStyle(.spoonBlack)
                .padding(.bottom, 8)
            
            let introText = store.introduction.isEmpty ? "안녕! 난 어떤 스푼이냐면…" : store.introduction
                
            Text(introText)
                .customFont(.caption1m)
                .foregroundStyle(.gray600)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
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
}

// MARK: - Profile Reviews View
struct ProfileReviewsView: View {
    @Bindable var store: StoreOf<ProfileFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            reviewsHeader
            reviewsContent
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
    
    private var reviewsContent: some View {
        Group {
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
    
    private var reviewsLoadingView: some View {
        VStack {
            ProgressView()
                .padding(.top, 30)
                .frame(maxWidth: .infinity)
            Text("리뷰를 불러오는 중...")
                .customFont(.caption1m)
                .foregroundStyle(.gray500)
                .padding(.top, 8)
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
            
            Button("다시 시도") {
                store.send(.fetchUserReviews)
            }
            .buttonStyle(.borderless)
            .foregroundColor(.main400)
            .padding(.top, 8)
        }
    }
    
    private func reviewListView(_ reviews: [FeedEntity]) -> some View {
        LazyVStack(spacing: 18) {
            ForEach(reviews) { review in
                ExploreCell(
                    feed: review,
                    onDelete: { postId in
                        store.send(.deleteReview(postId))
                    },
                    onEdit: { feed in
                        store.send(.routeToEditReviewScreen(feed.postId))
                    }
                )
                .padding(.horizontal, 20)
                .onTapGesture {
                    store.send(.routeToReviewDetail(review.postId))
                }
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 70)
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
                title: "등록하러 가기",
                isIcon: false,
                disabled: .constant(false)
            ) {
                store.send(.routeToRegister)
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

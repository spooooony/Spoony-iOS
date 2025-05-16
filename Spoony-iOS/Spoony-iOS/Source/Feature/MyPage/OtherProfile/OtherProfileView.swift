//
//  OtherProfileView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 5/15/25.
//

import SwiftUI
import ComposableArchitecture

struct OtherProfileView: View {
    @Bindable private var store: StoreOf<OtherProfileFeature>
    
    init(store: StoreOf<OtherProfileFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            ScrollView {
                VStack(spacing: 0) {
                    profileContentView
                }
            }
            .refreshable {
                store.send(.onAppear)
            }
        }
        .task {
            store.send(.onAppear)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    private var navigationBar: some View {
        CustomNavigationBar(
            style: .detail,
            title: store.username.isEmpty ? "프로필" : store.username,
            onBackTapped: {
                store.send(.routeToPreviousScreen)
            }
        )
        .padding(.bottom, 24)
    }
    
    private var profileContentView: some View {
        VStack(spacing: 0) {
            profileSection
            
            Divider()
                .frame(height: 2)
                .background(Color.gray0)
            
            reviewsSection
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
            profileImage
            
            Spacer()
            
            statsCounters
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
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
                    case .failure(_):
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
            statCounter(title: "리뷰", count: store.reviewCount)
            statCounter(title: "팔로워", count: store.followerCount)
            statCounter(title: "팔로잉", count: store.followingCount)
        }
    }
    
    private func statCounter(title: String, count: Int) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .customFont(.caption1b)
                .foregroundStyle(.gray400)
            Text("\(count)")
                .customFont(.body1sb)
                .foregroundStyle(.spoonBlack)
        }
    }
    
    private var profileInfo: some View {
        HStack(alignment: .center, spacing: 0) {
            userInfoSection
            
            Spacer()
            
            followButton
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 27)
    }
    
    private var userInfoSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            // 지역 정보 표시
            if !store.location.isEmpty {
                Text("서울 \(store.location) 스푼")
                    .customFont(.body2sb)
                    .foregroundStyle(.gray600)
                    .padding(.bottom, 4)
            }
            
            // 사용자 이름
            Text(store.username.isEmpty ? "이름 없음" : store.username)
                .customFont(.title3sb)
                .foregroundStyle(.spoonBlack)
                .padding(.bottom, 8)
            
            // 자기소개
            if !store.introduction.isEmpty {
                Text(store.introduction)
                    .customFont(.caption1m)
                    .foregroundStyle(.gray600)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
            }
        }
    }
    
    private var followButton: some View {
        FollowButton(
            isFollowing: store.isFollowing,
            action: {
                store.send(.followButtonTapped)
            }
        )
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
                    onDelete: nil,
                    onEdit: nil
                )
                .padding(.horizontal, 20)
            }
        }
        .padding(.top, 16)
    }
    
    private var emptyReviewsView: some View {
        VStack(spacing: 16) {
            Image(.imageGoToList)
                .resizable()
                .frame(width: 100, height: 100)
                .padding(.top, 30)
            
            Text("아직 등록한 리뷰가 없어요")
                .customFont(.body1m)
                .foregroundStyle(.gray500)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
    }
}

#Preview {
    OtherProfileView(
        store: Store(initialState: OtherProfileFeature.State(userId: 2)) {
            OtherProfileFeature()
        }
    )
}

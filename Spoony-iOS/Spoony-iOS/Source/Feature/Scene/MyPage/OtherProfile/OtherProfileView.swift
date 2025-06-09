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
        ZStack {
            mainContent
            overlayContent
            alertViews
        }
        .task { store.send(.onAppear) }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden()
        .toastView(toast: Binding(get: { store.toast }, set: { _ in }))
    }
}

private extension OtherProfileView {
    var mainContent: some View {
        VStack(spacing: 0) {
            navigationBar
            scrollableContent
        }
    }
    
    var scrollableContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                profileSection
                Divider().frame(height: 2).background(Color.gray0)
                reviewsSection
            }
        }
        .refreshable { store.send(.onAppear) }
    }
    
    var navigationBar: some View {
        CustomNavigationBar(
            style: store.isBlocked ? .detail : .detailWithKebab,
            title: "",
            onBackTapped: { store.send(.routeToPreviousScreen) },
            onKebabTapped: store.isBlocked ? nil : { store.send(.kebabMenuTapped) }
        )
        .padding(.bottom, 3)
    }
}

private extension OtherProfileView {
    var overlayContent: some View {
        Group {
            if store.isMenuPresented && !store.isBlocked {
                dropdownMenu
            }
        }
    }
    
    var dropdownMenu: some View {
        VStack {
            HStack {
                Spacer()
                DropDownMenu(
                    items: ["차단하기", "신고하기"],
                    isPresented: Binding(
                        get: { store.isMenuPresented },
                        set: { _ in store.send(.dismissMenu) }
                    )
                ) { item in
                    store.send(.menuItemSelected(item))
                }
                .offset(x: -5)
            }
            .padding(.top, 36)
            .padding(.trailing, 16)
            Spacer()
        }
    }
    
    var alertViews: some View {
        Group {
            if store.showBlockAlert { blockAlert }
            if store.showUnblockAlert { unblockAlert }
        }
    }
    
    var blockAlert: some View {
        CustomAlertView(
            title: "\(store.username)님을\n 차단하시겠습니까?",
            cancelTitle: "아니요",
            confirmTitle: "네",
            cancelAction: { store.send(.cancelBlock) },
            confirmAction: { store.send(.confirmBlock) }
        )
    }
    
    var unblockAlert: some View {
        CustomAlertView(
            title: "차단을 해제하시겠습니까?",
            cancelTitle: "아니요",
            confirmTitle: "네",
            cancelAction: { store.send(.cancelUnblock) },
            confirmAction: { store.send(.confirmUnblock) }
        )
    }
}

private extension OtherProfileView {
    var profileSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            profileHeader
            profileInfo
        }
    }
    
    var profileHeader: some View {
        HStack(alignment: .center, spacing: 39) {
            profileImage
            statsCounters
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }
    
    var profileImage: some View {
        Group {
            if !store.profileImageUrl.isEmpty && !store.isBlocked {
                AsyncImage(url: URL(string: store.profileImageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
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
    
    var defaultProfileImage: some View {
        Circle()
            .fill(Color.gray200)
            .frame(width: 85.adjusted, height: 85.adjustedH)
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: 35))
                    .foregroundColor(.gray400)
            )
    }
    
    var statsCounters: some View {
        HStack(spacing: 54) {
            statCounter(title: "리뷰", count: store.isBlocked ? 0 : store.reviewCount) {
            }
            
            statCounter(title: "팔로워", count: store.isBlocked ? 0 : store.followerCount) {
                if !store.isBlocked {
                    store.send(.routeToFollowerScreen)
                }
            }
            
            statCounter(title: "팔로잉", count: store.isBlocked ? 0 : store.followingCount) {
                if !store.isBlocked {
                    store.send(.routeToFollowingScreen)
                }
            }
        }
    }
    
    func statCounter(title: String, count: Int, action: @escaping () -> Void = {}) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .customFont(.caption1b)
                .foregroundStyle(.gray400)
                .lineLimit(1)
            Text("\(count)")
                .customFont(.body1sb)
                .foregroundStyle(.spoonBlack)
        }
        .onTapGesture(perform: action)
    }
    
    var profileInfo: some View {
        HStack(alignment: .center, spacing: 0) {
            userInfoSection
            Spacer()
            actionButton
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 27)
    }
    
    var userInfoSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            if !store.location.isEmpty {
                Text("서울 \(store.location) 스푼")
                    .customFont(.body2sb)
                    .foregroundStyle(.gray600)
                    .padding(.bottom, 4)
            }
            
            Text(store.username.isEmpty ? "이름 없음" : store.username)
                .customFont(.title3sb)
                .foregroundStyle(.spoonBlack)
                .padding(.bottom, 8)
            
            if !store.introduction.isEmpty {
                Text(store.introduction)
                    .customFont(.caption1m)
                    .foregroundStyle(.gray600)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
            }
        }
    }
    
    var actionButton: some View {
        Group {
            if store.isBlocked {
                unblockButton
            } else {
                FollowButton(
                    isFollowing: store.isFollowing,
                    action: { store.send(.followButtonTapped) }
                )
            }
        }
    }
    
    var unblockButton: some View {
        Button(action: { store.send(.followButtonTapped) }) {
            Text("차단 해제")
                .font(.body2sb)
                .foregroundColor(.white)
                .padding(.horizontal, 14.adjusted)
                .padding(.vertical, 8.adjustedH)
                .background(
                    EllipticalGradient(
                        stops: [
                            .init(color: .main400, location: 0.55),
                            .init(color: .main100, location: 1.0)
                        ],
                        center: UnitPoint(x: 1, y: 0),
                        startRadiusFraction: 0.28,
                        endRadiusFraction: 1.3
                    )
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.main200, lineWidth: 1)
                )
        }
    }
}

private extension OtherProfileView {
    var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            reviewsHeader
            reviewsContent
        }
    }
    
    var reviewsHeader: some View {
        HStack {
            Text("리뷰").customFont(.body1b).foregroundStyle(.spoonBlack)
            Text("\(store.isBlocked ? 0 : store.reviewCount)개").customFont(.body2m).foregroundStyle(.gray400)
        }
        .padding(.horizontal, 20)
        .padding(.top, 19)
    }
    
    var reviewsContent: some View {
        Group {
            if store.isBlocked {
                blockedUserReviewsView
            } else if store.isLoadingReviews {
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
    
    var blockedUserReviewsView: some View {
        VStack(spacing: 16) {
            Image(.imageGoToList)
                .resizable()
                .frame(width: 100, height: 100)
                .padding(.top, 30)
            
            VStack(spacing: 8) {
                Text("차단된 사용자예요.")
                    .customFont(.body2b)
                    .foregroundStyle(.gray400)
                
                Text("지금은 프로필을 볼 수 없지만, \n 원하시면 차단을 해제할 수 있어요.")
                    .customFont(.body2m)
                    .foregroundStyle(.gray500)
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
    }
    
    var reviewsLoadingView: some View {
        VStack {
            ProgressView().padding(.top, 30)
            Text("리뷰를 불러오는 중...")
                .customFont(.caption1m)
                .foregroundStyle(.gray500)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
    }
    
    func reviewsErrorView(_ error: String) -> some View {
        VStack {
            Text("리뷰를 불러오는데 실패했습니다.")
                .customFont(.body2m)
                .foregroundStyle(.gray600)
                .multilineTextAlignment(.center)
                .padding(.top, 30)
            
            Button("다시 시도") { store.send(.fetchUserReviews) }
                .buttonStyle(.borderless)
                .foregroundColor(.main400)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
    }
    
    func reviewListView(_ reviews: [FeedEntity]) -> some View {
        LazyVStack(spacing: 18) {
            ForEach(reviews) { review in
                ExploreCell(feed: review, onDelete: nil, onEdit: nil)
                    .padding(.horizontal, 20)
                    .onTapGesture {
                        store.send(.routeToReviewDetail(review.postId))
                    }
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 100)
    }
    
    var emptyReviewsView: some View {
        VStack(spacing: 16) {
            Image(.imageGoToList)
                .resizable()
                .frame(width: 100.adjusted, height: 100.adjustedH)
                .padding(.top, 30)
            
            Text("아직 등록한 리뷰가 없어요")
                .customFont(.body1m)
                .foregroundStyle(.gray500)
                .multilineTextAlignment(.center)
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

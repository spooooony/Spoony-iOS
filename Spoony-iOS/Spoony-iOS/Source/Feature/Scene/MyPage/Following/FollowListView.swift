//
//  FollowListView.swift
//  Spoony-iOS
//
//  Created by 이명진 on 4/23/25.
//

import SwiftUI
import ComposableArchitecture

struct FollowListView: View {
    
    // MARK: - Properties
    
    @Bindable var store: StoreOf<FollowFeature>
    
    @Namespace private var tabNamespace
    @State private var currentTab: Int = 0
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            
            CustomNavigationBar(style: .backOnly, onBackTapped: {
                store.send(.routeToPreviousScreen)
            })
            
            pageControlSection
            
            separatorSection
            
            listSection
        }
        .task {
            await store.send(.onAppear).finish()
        }
        .onAppear {
            currentTab = store.initialTab
        }
    }
}

extension FollowListView {
    
    // MARK: - 상단 페이지 컨트롤
    
    private var pageControlSection: some View {
        let tabs = [
            "팔로워 \(store.followerCount)",
            "팔로잉 \(store.followingCount)"
        ]
        
        return HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { index in
                Button {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        currentTab = index
                    }
                } label: {
                    VStack(spacing: 9.adjustedH) {
                        Text(tabs[index])
                            .font(.body1sb)
                            .foregroundColor(currentTab == index ? .main400 : .gray400)
                        
                        ZStack {
                            if currentTab == index {
                                Rectangle()
                                    .fill(Color.main400)
                                    .frame(height: 2.adjustedH)
                                    .matchedGeometryEffect(id: "underline", in: tabNamespace)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: currentTab)
    }
    
    // MARK: - Separator
    
    private var separatorSection: some View {
        Rectangle()
            .fill(Color.gray0)
            .frame(height: 10.adjustedH)
    }
    
    // MARK: - 하단 팔로워, 팔로잉 리스트
    
    private var listSection: some View {
        TabView(selection: $currentTab) {
            List {
                ForEach(store.followerList, id: \.userId) { user in
                    FollowRow(
                        user: user,
                        onFollowTap: {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            store.send(.followButtonTapped(userId: user.userId, isFollowing: user.isFollowing))
                        },
                        onUserTap: {
                            if user.isMine {
                                store.send(.routeToMyProfileScreen)
                            } else {
                                store.send(.routeToUserProfileScreen(userId: user.userId))
                            }
                        }
                    )
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .alignmentGuide(.listRowSeparatorLeading) {
                        $0[.leading]
                    }
                }
            }
            .listStyle(.plain)
            .refreshable {
                await store.send(.onAppear).finish()
            }
            .tag(0)
            
            List {
                ForEach(store.followingList, id: \.userId) { user in
                    FollowRow(
                        user: user,
                        onFollowTap: {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            store.send(.followButtonTapped(userId: user.userId, isFollowing: user.isFollowing))
                        },
                        onUserTap: {
                            if user.isMine {
                                store.send(.routeToMyProfileScreen)
                            } else {
                                store.send(.routeToUserProfileScreen(userId: user.userId))
                            }
                        }
                    )
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .alignmentGuide(.listRowSeparatorLeading) {
                        $0[.leading]
                    }
                }
            }
            .listStyle(.plain)
            .refreshable {
                await store.send(.onAppear).finish()
            }
            .tag(1)
        }
        .onAppear {
            currentTab = store.initialTab
        }
        .onChange(of: currentTab) { newValue in
            store.send(.currentTabChanged(newValue))
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

struct FollowRow: View {
    let user: FollowUserDTO
    let onFollowTap: () -> Void
    let onUserTap: () -> Void
    
    var body: some View {
        HStack(spacing: 16.adjusted) {
            AsyncImage(url: URL(string: user.profileImageUrl)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60.adjusted, height: 60.adjustedH)
                        .clipShape(Circle())
                case .failure(_), .empty:
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60.adjusted, height: 60.adjustedH)
                @unknown default:
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60.adjusted, height: 60.adjustedH)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(user.username)
                    .font(.body2sb)
                Text("서울 \(user.regionName ?? "") 스푼")
                    .font(.caption1m)
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            if !user.isMine {
                FollowButton(isFollowing: user.isFollowing, action: onFollowTap)
                    .contentShape(Rectangle())
                    .buttonStyle(.borderless)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onUserTap()
        }
        .padding(.horizontal, 20.adjusted)
        .padding(.vertical, 14.5.adjustedH)
    }
}

#Preview {
    FollowListView(
        store: Store(initialState: .init(), reducer: { FollowFeature() })
    )
}

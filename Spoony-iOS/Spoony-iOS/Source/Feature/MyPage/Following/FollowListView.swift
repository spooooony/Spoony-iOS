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
            pageControlSection
            
            separatorSection
            
            listSection
        }
        .task {
            await store.send(.onAppear).finish()
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
                    FollowRow(user: user) {
                        store.send(.followButtonTapped(userId: user.userId, isFollowing: user.isFollowing))
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .alignmentGuide(.listRowSeparatorLeading) {
                        $0[.leading]
                    }
                }
            }
            .listStyle(.plain)
            .tag(0)
            
            List {
                ForEach(store.followingList, id: \.userId) { user in
                    FollowRow(user: user) {
                        store.send(.followButtonTapped(userId: user.userId, isFollowing: user.isFollowing))
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .alignmentGuide(.listRowSeparatorLeading) {
                        $0[.leading]
                    }
                }
            }
            .listStyle(.plain)
            .tag(1)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

struct FollowRow: View {
    let user: FollowUserDTO
    let onFollowTap: () -> Void
    
    var body: some View {
        HStack(spacing: 16.adjusted) {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60.adjusted, height: 60.adjustedH)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(user.username)
                    .font(.body2sb)
                Text("서울 \(user.regionName) 스푼")
                    .font(.caption1m)
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            FollowButton(isFollowing: user.isFollowing, action: onFollowTap)
                .contentShape(Rectangle())
                .buttonStyle(.borderless)
        }
        .contentShape(Rectangle()) // 전체 HStack을 터치영역으로
        .onTapGesture {
            print("프로필로 이동: \(user.username)")
            // TODO: UserProfile 로직 추가
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

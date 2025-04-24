//
//  FollowListView.swift
//  Spoony-iOS
//
//  Created by 이명진 on 4/23/25.
//

import SwiftUI

struct FollowListView: View {
    
    // MARK: - Properties
    
    @Namespace private var tabNamespace
    @State private var currentTab: Int = 0
    
    private let tabs = ["팔로워 1000", "팔로잉 12"]
    private let follows: [FollowModel] = FollowModel.dummyData()
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            pageControlSection
            
            separatorSection
            
            listSection
        }
    }
}

extension FollowListView {
    
    // MARK: - 상단 페이지 컨트롤
    
    private var pageControlSection: some View {
        HStack(spacing: 0) {
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
                                    .fill(.main400)
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
                ForEach(follows, id: \.userId) { user in
                    FollowRow(user: user)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                            return -viewDimensions.width
                        }
                }
            }
            .listStyle(.plain)
            .tag(0)
            
            List {
                ForEach(follows.filter { $0.isFollowing }, id: \.userId) { user in
                    FollowRow(user: user)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                            return -viewDimensions.width
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
    let user: FollowModel
    
    var body: some View {
        HStack(spacing: 16.adjusted) {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60.adjusted, height: 60.adjustedH)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(user.username)
                    .font(.body2sb)
                Text("서울 \(user.location) 스푼")
                    .font(.caption1m)
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            FollowButton(isFollowing: user.isFollowing) {
                print("팔로우 버튼 탭됨: \(user.username)")
                // TODO: 팔로우 언팔로직 넣어야함
            }
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
    FollowListView()
}

//
//  BlockedUsersView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/25/25.
//

import SwiftUI
import ComposableArchitecture

struct BlockedUsersView: View {
    @Bindable private var store: StoreOf<BlockedUsersFeature>
    
    init(store: StoreOf<BlockedUsersFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                style: .detail,
                title: "차단한 유저",
                onBackTapped: {
                    store.send(.routeToPreviousScreen)
                }
            )
            
            if store.isLoading {
                loadingView
            } else if let error = store.errorMessage {
                errorView(error)
            } else if store.blockedUsers.isEmpty {
                emptyStateView
            } else {
                blockedUsersList
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .task {
            store.send(.onAppear)
        }
    }
    
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Spacer()
        }
    }
    
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "exclamationmark.triangle")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray300)
                .padding(.bottom, 8)
            
            Text("사용자 정보를 불러오는데 실패했습니다")
                .customFont(.body1sb)
                .foregroundColor(.gray600)
            
            Text(error)
                .customFont(.caption1m)
                .foregroundColor(.gray400)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                store.send(.fetchBlockedUsers)
            }) {
                Text("다시 시도")
                    .customFont(.body2sb)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.main400)
                    )
            }
            .padding(.top, 16)
            
            Spacer()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(.imageGoToList)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(.bottom, 8)
            
            Text("차단한 유저가 없습니다")
                .customFont(.body2m)
                .foregroundColor(.gray500)
            
            Spacer()
        }
    }
    
    private var blockedUsersList: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.gray0)
                .frame(height: 10.adjustedH)
            
            List {
                ForEach(store.blockedUsers, id: \.userId) { user in
                    BlockedUserRow(
                        user: user,
                        isProcessing: store.processingUserIds.contains(user.userId),
                        unblockAction: {
                            store.send(.unblockUser(user.userId))
                        }
                    )
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
                }
            }
            .listStyle(.plain)
        }
    }
}

struct BlockedUserRow: View {
    let user: BlockedUserModel
    let isProcessing: Bool
    let unblockAction: () -> Void
    
    var body: some View {
        HStack(spacing: 16.adjusted) {
            // 프로필 이미지
            AsyncImage(url: URL(string: user.profileImageUrl)) { phase in
                if let image = phase.image {
                    image.resizable()
                } else if phase.error != nil {
                    Circle().fill(Color.gray200)
                } else {
                    Circle().fill(Color.gray200)
                }
            }
            .frame(width: 60.adjusted, height: 60.adjustedH)
            .clipShape(Circle())
            
            // 유저 정보
            VStack(alignment: .leading, spacing: 2) {
                Text(user.username)
                    .customFont(.body2sb)
                    .foregroundColor(.spoonBlack)
                
                Text("서울 \(user.regionName) 스푼")
                    .customFont(.caption1m)
                    .foregroundColor(.gray600)
            }
            
            Spacer()
            
            // 차단 해제 버튼
            BlockButton(isProcessing: isProcessing, action: unblockAction)
                .contentShape(Rectangle())
                .buttonStyle(.borderless)
        }
        .contentShape(Rectangle())
        .padding(.horizontal, 20.adjusted)
        .padding(.vertical, 14.5.adjustedH)
    }
}

struct BlockButton: View {
    var isProcessing: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if isProcessing {
                    ProgressView()
                        .scaleEffect(0.7)
                        .tint(.gray500)
                } else {
                    Text("해제")
                        .customFont(.body2sb)
                        .foregroundColor(.gray500)
                }
            }
            .padding(.horizontal, 14.adjusted)
            .padding(.vertical, 8.adjustedH)
            .background(Color.gray0)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.gray100, lineWidth: 1)
            )
        }
        .disabled(isProcessing)
    }
}

#Preview {
    BlockedUsersView(
        store: Store(initialState: .initialState) {
            BlockedUsersFeature()
        }
    )
}

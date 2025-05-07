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
    
    private let blockedUsers: [BlockedUserModel] = BlockedUserModel.dummyData()
    
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
            
            if blockedUsers.isEmpty {
                emptyStateView
            } else {
                blockedUsersList
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
    }
    // TODO: 디자인추가되면 만들어야징
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "person.slash")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray300)
                .padding(.bottom, 8)
            
            Text("차단한 유저가 없습니다")
                .customFont(.body1sb)
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
                ForEach(blockedUsers, id: \.userId) { user in
                    BlockedUserRow(user: user, isBlocked: user.userId != 3) {
                        print("차단 상태 변경: \(user.username)")
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .alignmentGuide(.listRowSeparatorLeading) {
                        $0[.leading]
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}

struct BlockedUserRow: View {
    let user: BlockedUserModel
    let isBlocked: Bool
    let blockAction: () -> Void
    
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
            
            BlockButton(isBlocked: isBlocked) {
                blockAction()
            }
            .contentShape(Rectangle())
            .buttonStyle(.borderless)
        }
        .contentShape(Rectangle())
        .padding(.horizontal, 20.adjusted)
        .padding(.vertical, 14.5.adjustedH)
    }
}

struct BlockButton: View {
    var isBlocked: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(isBlocked ? "해제" : "차단")
                .font(.body2sb)
                .foregroundColor(isBlocked ? .gray500 : .white)
                .padding(.horizontal, 14.adjusted)
                .padding(.vertical, 8.adjustedH)
                .background(
                    Group {
                        if isBlocked {
                            Color(.systemGray6)
                        } else {
                            EllipticalGradient(
                                stops: [
                                    .init(color: .main400, location: 0.55),
                                    .init(color: .main100, location: 1.0)
                                ],
                                center: UnitPoint(x: 1, y: 0),
                                startRadiusFraction: 0.28,
                                endRadiusFraction: 1.3
                            )
                        }
                    }
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(isBlocked ? Color.gray100 : Color.main200, lineWidth: 1)
                )
        }
    }
}

struct BlockedUserModel: Codable, Identifiable {
    let id = UUID()
    let userId: Int
    let username: String
    let location: String
    let blockDate: Date
    
    static func dummyData() -> [BlockedUserModel] {
        return [
            BlockedUserModel(userId: 1, username: "바밥바", location: "마포구", blockDate: Date()),
            BlockedUserModel(userId: 2, username: "수박바", location: "은평구", blockDate: Date().addingTimeInterval(-86400)),
            BlockedUserModel(userId: 3, username: "메가톤바", location: "강남구", blockDate: Date().addingTimeInterval(-172800))
        ]
    }
}

#Preview {
    BlockedUsersView(
        store: Store(initialState: .initialState) {
            BlockedUsersFeature()
        }
    )
}

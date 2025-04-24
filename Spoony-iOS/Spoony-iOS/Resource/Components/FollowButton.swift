//
//  FollowButton.swift
//  Spoony-iOS
//
//  Created by 이명진 on 4/24/25.
//

import SwiftUI

struct FollowButton: View {
    
    // MARK: - Properties
    
    var isFollowing: Bool
    var action: () -> Void
    
    // MARK: - Init
    
    init(isFollowing: Bool, action: @escaping () -> Void) {
        self.isFollowing = isFollowing
        self.action = action
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(action: action) {
            Text(isFollowing ? "팔로잉" : "팔로우")
                .font(.body2sb)
                .foregroundColor(isFollowing ? .gray500 : .white)
                .padding(.horizontal, 14.adjusted)
                .padding(.vertical, 8.adjustedH)
                .background(
                    Group {
                        if isFollowing {
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
                        .strokeBorder(isFollowing ? .gray100 : .main200, lineWidth: 1)
                )
        }
    }
}

// MARK: - Preview

#Preview {
    FollowButton(isFollowing: true) {
        print("ㅎㅇ")
    }
    FollowButton(isFollowing: false) {
        print("ㅎㅇ")
    }
}

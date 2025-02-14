//
//  EmptyStateBottomSheet.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 2/10/25.
//

import SwiftUI

import FlexSheet

struct EmptyStateBottomSheet: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    
    private let fixedStyle = FlexSheetStyle(
        fixedHeight: UIScreen.main.bounds.height * 0.5
    )
    
    var body: some View {
        FixedBottomSheet(style: fixedStyle) {
            VStack(spacing: 16) {
                Image(.imageGoToList)
                    .resizable()
                    .frame(width: 100.adjusted, height: 100.adjustedH)
                
                Text("아직 추가된 장소가 없어요.\n다른 사람의 리스트를 떠먹어 보세요!")
                    .customFont(.body2m)
                    .foregroundStyle(.gray500)
                    .multilineTextAlignment(.center)
                
                SpoonyButton(
                    style: .secondary,
                    size: .xsmall,
                    title: "떠먹으러 가기",
                    disabled: .constant(false) 
                ) {
                    navigationManager.selectedTab = .explore
                }
                .padding(.top, 8)
            }
            .padding(.top, 24)
        }
    }
}

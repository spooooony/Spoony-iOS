//
//  FixedBottomSheetView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/18/25.
//

import SwiftUI
import ComposableArchitecture

struct FixedBottomSheetView: View {
    private let store: StoreOf<MapFeature>
    private let screenHeight = UIScreen.main.bounds.height
    private let fixedHeight: CGFloat
    private let headerHeight: CGFloat = 20.adjustedH
    @State private var isDisabled = false
    
    init(store: StoreOf<MapFeature>) {
        self.store = store
        self.fixedHeight = UIScreen.main.bounds.height * 0.5
    }
    
    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 10) {
                VStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray300)
                        .frame(width: 36.adjusted, height: 2.adjustedH)
                        .padding(.top, 10)
                }
                .frame(height: headerHeight)
                .background(Color.white)
                
                VStack(spacing: 16) {
                    Image(.imageGoToList)
                        .resizable()
                        .frame(width: 100.adjusted, height: 100.adjustedH)
                    
                    Text("아직 추가된 장소가 없어요.\n다른 사람의 리스트를 떠먹어 보세요!")
                        .customFont(.body2m)
                        .foregroundStyle(Color.gray500)
                        .multilineTextAlignment(.center)
                    
                    SpoonyButton(
                        style: .primary,
                        size: .xsmall,
                        title: "떠먹으러 가기",
                        disabled: $isDisabled
                    ) {
                        store.send(.routToExploreTab)
                    }
                    .padding(.top, 8)
                }
                .padding(.top, 24)
                
                Spacer()
            }
            .frame(height: fixedHeight)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10, corners: [.topLeft, .topRight])
            .offset(y: screenHeight - fixedHeight)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    FixedBottomSheetView(
        store: Store(initialState: .initialState) {
            MapFeature()
        }
    )
}

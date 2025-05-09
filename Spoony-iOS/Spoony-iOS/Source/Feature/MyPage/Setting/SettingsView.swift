//
//  SettingsView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/13/25.
//

import SwiftUI

import ComposableArchitecture
import TCACoordinators

struct SettingsView: View {
    @Bindable private var store: StoreOf<SettingsFeature>
    
    init(store: StoreOf<SettingsFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                style: .detail,
                title: "설정",
                searchText: .constant(""),
                onBackTapped: {
                    store.send(.routeToPreviousScreen)
                }
            )
            
            VStack(spacing: 0) {
                sectionHeader(title: "계정")
                
                settingsRow(title: "계정 관리", hasArrow: true) {
                    store.send(.didTapAccountManagement)
                }
                
                sectionHeader(title: "기타")
                
                settingsRow(title: "차단한 유저", hasArrow: true) {
                    store.send(.didTapBlockedUsers)
                }
                Divider()
                    .padding(.leading, 20)
                
                settingsRow(title: "서비스 이용약관", hasArrow: true) {
                    URLHelper.openURL(Config.termsOfServiceURL)
                }
                
                settingsRow(title: "개인정보 처리 방침", hasArrow: true) {
                    URLHelper.openURL(Config.privacyPolicyURL)
                }
                
                settingsRow(title: "위치기반서비스 이용약관", hasArrow: true) {
                    URLHelper.openURL(Config.locationServicesURL)
                }
                
                settingsRow(title: "1:1 문의", hasArrow: true) {
                    URLHelper.openURL(Config.inquiryURL)
                }
            Spacer()
        }
    }
        .background(Color.white)
        .task {
            store.send(.onAppear)
        }
}

private func sectionHeader(title: String) -> some View {
    HStack {
        Text(title)
            .font(.caption1m)
            .foregroundStyle(.gray600)
            .padding(.leading, 20)
            .padding(.vertical, 8)
        
        Spacer()
    }
    .frame(maxWidth: .infinity)
    .background(Color.gray0)
}

private func settingsRow(title: String, hasArrow: Bool = false, action: (() -> Void)? = nil) -> some View {
    Button(action: {
        action?()
    }) {
        HStack {
            Text(title)
                .font(.body2m)
                .foregroundStyle(.gray700)
                .padding(.vertical, 16)
            
            Spacer()
            
            if hasArrow {
                Image(.icArrowRightGray400)
            }
        }
        .padding(.horizontal, 20)
        .background(Color.white)
    }
    .buttonStyle(PlainButtonStyle())
}
}

#Preview {
    NavigationView {
        SettingsView(store: Store(initialState: .initialState, reducer: {
            SettingsFeature()
        }))
    }
}

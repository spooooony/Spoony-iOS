//
//  MyPageView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/11/25.
//

import SwiftUI

import ComposableArchitecture
import TCACoordinators

@Reducer(state: .equatable)
enum MyPageScreen {
    case profile(ProfileFeature)
    case otherProfile(OtherProfileFeature)
    case reviews(RegisterFeature)
    case follow(FollowFeature)
    case editProfile(EditProfileFeature)
    case settings(SettingsFeature)
    case attendance(AttendanceFeature)
    
    case accountManagement(AccountManagementFeature)
    case blockedUsers(BlockedUsersFeature)
    case termsOfService(TermsOfServiceFeature)
    case privacyPolicy(PrivacyPolicyFeature)
    case locationServices(LocationServicesFeature)
    case inquiry(InquiryFeature)
    
    case logout(LogoutFeature)
    case withdraw(WithdrawFeature)
}

struct MyPageCoordinatorView: View {
    @Bindable private var store: StoreOf<MyPageCoordinator>
    
    init(store: StoreOf<MyPageCoordinator>) {
        self.store = store
    }
    
    var body: some View {
        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            switch screen.case {
            case let .profile(store):
                ProfileView(store: store)
                    .navigationBarBackButtonHidden()
            case let .otherProfile(store):
                OtherProfileView(store: store)
                    .navigationBarBackButtonHidden()
            case let .reviews(store):
                Register(store: store)
            case let .follow(store):
                FollowListView(store: store)
                    .navigationBarBackButtonHidden()
            case let .editProfile(store):
                EditProfileView(store: store)
            case let .settings(store):
                SettingsView(store: store)
            case let .attendance(store):
                AttendanceView(store: store)
                    .navigationBarBackButtonHidden()
                    .toolbar(.hidden, for: .tabBar)
                    
                // 설정 관련 화면들 추가
            case let .accountManagement(store):
                AccountManagementView(store: store)
                    .navigationBarBackButtonHidden()
            case let .blockedUsers(store):
                BlockedUsersView(store: store)
                    .navigationBarBackButtonHidden()
            case let .termsOfService(store):
                TermsOfServiceView(store: store)
                    .navigationBarBackButtonHidden()
            case let .privacyPolicy(store):
                PrivacyPolicyView(store: store)
                    .navigationBarBackButtonHidden()
            case let .locationServices(store):
                LocationServicesView(store: store)
                    .navigationBarBackButtonHidden()
            case let .inquiry(store):
                InquiryView(store: store)
                    .navigationBarBackButtonHidden()
                
            case let .logout(store):
                LogoutView(store: store)
                    .navigationBarBackButtonHidden()
            case let .withdraw(store):
                WithdrawView(store: store)
                    .navigationBarBackButtonHidden()
            }
        }
    }
}

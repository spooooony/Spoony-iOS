//
//  SettingFeature.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/13/25.
//

import SwiftUI

import ComposableArchitecture
import TCACoordinators

enum SettingsScreenType {
    case accountManagement
    case blockedUsers
    case termsOfService
    case privacyPolicy
    case locationServices
    case inquiry
}

@Reducer
struct SettingsFeature {
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
        
        var isLoading: Bool = false
    }
    
    enum Action {
        case onAppear
        case didTapAccountManagement
        case didTapBlockedUsers
        case didTapServiceTerms
        case didTapPrivacyPolicy
        case didTapLocationServices
        case didTapInquiry
        
        // MARK: - Route Action: 화면 전환 이벤트를 상위 Reducer에 전달 시 사용
        case delegate(Delegate)
        enum Delegate {
            case routeToAccountManagementScreen
            case routeToBlockedUsersScreen
            case routeToPreviousScreen
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case .didTapAccountManagement:
                return .send(.delegate(.routeToAccountManagementScreen))
                
            case .didTapBlockedUsers:
                return .send(.delegate(.routeToBlockedUsersScreen))
                
            case .didTapServiceTerms:
                URLHelper.openURL(Config.termsOfServiceURL)
                return .none
                
            case .didTapPrivacyPolicy:
                URLHelper.openURL(Config.privacyPolicyURL)
                return .none
                
            case .didTapLocationServices:
                URLHelper.openURL(Config.locationServicesURL)
                return .none
                
            case .didTapInquiry:
                URLHelper.openURL(Config.inquiryURL)
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}

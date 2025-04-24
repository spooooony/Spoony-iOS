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
        var destination: SettingsScreenType?
    }
    
    enum Action {
        case routeToPreviousScreen
        case onAppear
        case didTapAccountManagement
        case didTapBlockedUsers
        case didTapServiceTerms
        case didTapPrivacyPolicy
        case didTapLocationServices
        case didTapInquiry
        case setDestination(SettingsScreenType?)
        
        // 실제 라우팅 액션 추가
        case routeToAccountManagementScreen
        case routeToBlockedUsersScreen
        case routeToTermsOfServiceScreen
        case routeToPrivacyPolicyScreen
        case routeToLocationServicesScreen
        case routeToInquiryScreen
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .routeToPreviousScreen:
                return .none
                
            case .onAppear:
                return .none
                
            case .didTapAccountManagement:
                return .send(.routeToAccountManagementScreen)
                
            case .didTapBlockedUsers:
                return .send(.routeToBlockedUsersScreen)
                
            case .didTapServiceTerms:
                return .send(.routeToTermsOfServiceScreen)
                
            case .didTapPrivacyPolicy:
                return .send(.routeToPrivacyPolicyScreen)
                
            case .didTapLocationServices:
                return .send(.routeToLocationServicesScreen)
                
            case .didTapInquiry:
                return .send(.routeToInquiryScreen)
                
            case let .setDestination(destination):
                state.destination = destination
                return .none
                
            case .routeToAccountManagementScreen,
                 .routeToBlockedUsersScreen,
                 .routeToTermsOfServiceScreen,
                 .routeToPrivacyPolicyScreen,
                 .routeToLocationServicesScreen,
                 .routeToInquiryScreen:
                return .none
            }
        }
    }
}

//
//  AgreeFeature.swift
//  Spoony-iOS
//
//  Created by 최주리 on 3/30/25.
//

import Foundation

import ComposableArchitecture

@Reducer
struct AgreeFeature {
    
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
        
        var allCheckboxFilled: Bool = false
        var isDisableButton: Bool = true
        var selectedAgrees: [AgreeType] = []
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case allAgreeTapped
        case agreeURLTapped(AgreeType)
        case selectedAgreeTapped(AgreeType)
        case unSelectedAgreeTapped(AgreeType)
        case selectedAgreesChanged
        
        // MARK: - Route Action: 화면 전환 이벤트를 상위 Reducer에 전달 시 사용
        case delegate(Delegate)
        enum Delegate {
            case routeToOnboardingScreen
        }
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .allAgreeTapped:
                if state.allCheckboxFilled {
                    state.selectedAgrees = []
                } else {
                    state.selectedAgrees = AgreeType.allCases
                }
                return .send(.selectedAgreesChanged)
                
            case .agreeURLTapped(let type):
                switch type {
                case .age:
                    break
                case .termsOfUse:
                    URLHelper.openURL(Config.termsOfServiceURL)
                case .privacyPolicy:
                    URLHelper.openURL(Config.privacyPolicyURL)
                case .locationPolicy:
                    URLHelper.openURL(Config.locationServicesURL)
                }
                return .none
                
            case .selectedAgreeTapped(let agree):
                if let index = state.selectedAgrees.firstIndex(of: agree) {
                    state.selectedAgrees.remove(at: index)
                    return .send(.selectedAgreesChanged)
                }
                return .none
                
            case .unSelectedAgreeTapped(let agree):
                state.selectedAgrees.append(agree)
                return .send(.selectedAgreesChanged)
                
            case .selectedAgreesChanged:
                state.allCheckboxFilled = state.selectedAgrees.count == AgreeType.allCases.count
                state.isDisableButton = !state.allCheckboxFilled
                return .none
                
            case .binding:
                return .none

            case .delegate:
                return .none
            }
        }
    }
    
}

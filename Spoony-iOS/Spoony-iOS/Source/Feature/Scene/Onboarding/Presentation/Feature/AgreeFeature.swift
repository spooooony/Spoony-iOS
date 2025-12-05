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
        case viewAction(ViewAction)
        case privateAction(PrivateAction)
        case delegate(Delegate)
        case binding(BindingAction<State>)
    }
    
    enum ViewAction {
        case allAgreeTapped
        case agreeURLTapped(AgreeType)
        case selectedAgreeTapped(AgreeType)
        case unSelectedAgreeTapped(AgreeType)
    }
    
    enum PrivateAction {
        case selectedAgreesChanged
    }
    
    enum Delegate: Equatable {
        case routeToOnboardingScreen
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            // MARK: - viewAction
            case .viewAction(.allAgreeTapped):
                if state.allCheckboxFilled {
                    state.selectedAgrees = []
                } else {
                    state.selectedAgrees = AgreeType.allCases
                }
                return .send(.privateAction(.selectedAgreesChanged))
                
            case .viewAction(.agreeURLTapped(let type)):
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
                
            case .viewAction(.selectedAgreeTapped(let agree)):
                if let index = state.selectedAgrees.firstIndex(of: agree) {
                    state.selectedAgrees.remove(at: index)
                    return .send(.privateAction(.selectedAgreesChanged))
                }
                return .none
                
            case .viewAction(.unSelectedAgreeTapped(let agree)):
                state.selectedAgrees.append(agree)
                return .send(.privateAction(.selectedAgreesChanged))
            
            // MARK: - privateAction
            case .privateAction(.selectedAgreesChanged):
                state.allCheckboxFilled = state.selectedAgrees.count == AgreeType.allCases.count
                state.isDisableButton = !state.allCheckboxFilled
                return .none
                
            default: return .none
            }
        }
    }
    
}

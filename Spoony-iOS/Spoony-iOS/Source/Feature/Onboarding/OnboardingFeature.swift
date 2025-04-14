//
//  OnboardingFeature.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/13/25.
//

import SwiftUI
import ComposableArchitecture

enum OnboardingStep: Int {
    case nickname = 1
    case information = 2
    case introduce = 3
    case finish
}

@Reducer
struct OnboardingFeature {
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
        
        var currentStep: OnboardingStep = .nickname
        var nicknameText: String = ""
        var nicknameError: Bool = true
        var nicknameErrorState: NicknameTextFieldErrorState = .initial
        
        // 임시
        var birth: String = ""
        var region: String = ""
        var infoError: Bool = true
        
        var introduceText: String = ""
        var introduceError: Bool = true
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case tappedNextButton
        case tappedBackButton
        case tappedSkipButton
            
        case checkNickname
        
        case tappedBirthButton
        case tappedRegionButton
        
        case selectBirth
        case selectRegion
        
        // MARK: - Navigation
        case routToTabCoordinatorScreen
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .tappedNextButton:
                switch state.currentStep {
                case .nickname:
                    state.currentStep = .information
                case .information:
                    state.currentStep = .introduce
                case .introduce:
                    state.currentStep = .finish
                case .finish:
                    return .send(.routToTabCoordinatorScreen)
                }
                print("\(state.currentStep)")
                return .none
                
            case .tappedBackButton:
                switch state.currentStep {
                case .nickname:
                    break
                case .information:
                    state.currentStep = .nickname
                case .introduce:
                    state.currentStep = .information
                case .finish:
                    break
                }
                print("\(state.currentStep)")
                return .none
                
            case .tappedSkipButton:
                state.currentStep = .finish
                print("\(state.currentStep)")
                return .none
            case .checkNickname:
                if state.nicknameErrorState == .noError {
                    // api
                    state.nicknameErrorState = .avaliableNickname
                }
                
                if state.nicknameErrorState == .avaliableNickname {
                    state.nicknameError = false
                }
                return .none
            case .tappedBirthButton:
                return .none
            case .tappedRegionButton:
                // 임시
                state.infoError = false
                return .none
            case .selectBirth:
                return .none
            case .selectRegion:
                return .none
                
            case .routToTabCoordinatorScreen:
                return .none
            case .binding:
                return .none
            }
        }
    }
}

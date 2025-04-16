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
        
        var birth: [String] = ["", "", ""]
        var region: LocationType = .seoul
        var subRegion: SubLocationType?
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
                case .nickname, .finish:
                    break
                case .information:
                    state.currentStep = .nickname
                case .introduce:
                    state.currentStep = .information
                }
                return .none
                
            case .tappedSkipButton:
                switch state.currentStep {
                case .nickname:
                    break
                case .information:
                    state.currentStep = .introduce
                case .introduce:
                    state.currentStep = .finish
                case .finish:
                    break
                }
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
            case .routToTabCoordinatorScreen:
                return .none
            case .binding(\.subRegion):
                if state.subRegion != nil {
                    state.infoError = false
                }
                return .none
            case .binding(\.birth):
                guard let year = state.birth.first else { return .none }
                
                if !year.isEmpty {
                    state.infoError = false
                }
                return .none
            case .binding:
                return .none
            }
        }
    }
}

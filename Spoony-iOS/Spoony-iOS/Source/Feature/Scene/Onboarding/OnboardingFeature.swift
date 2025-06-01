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

enum OnboardingError: Error {
    case networkError
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
        
        var regionList: [Region] = []
        
        var birth: [String] = ["", "", ""]
        var region: LocationType = .seoul
        var subRegion: Region?
        var infoError: Bool = true
        
        var introduceText: String = ""
        var introduceError: Bool = true
        
        var userNickname: String = ""
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case tappedNextButton
        case tappedBackButton
        case tappedSkipButton
        
        case infoStepViewOnAppear
        
        case checkNickname
        case signup
        
        case setUserNickname(String)
        case setNicknameError(NicknameTextFieldErrorState)
        case setRegion([Region])
        
        case error(Error)
        
        // MARK: - Navigation
        case routToTabCoordinatorScreen
    }
    
    private let authenticationManager = AuthenticationManager.shared
    @Dependency(\.authService) var authService: AuthProtocol
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce {
            state, action in
            switch action {
            case .tappedNextButton:
                switch state.currentStep {
                case .nickname:
                    state.currentStep = .information
                case .information:
                    state.currentStep = .introduce
                case .introduce:
                    return .send(.signup)
                case .finish:
                    return .send(.routToTabCoordinatorScreen)
                }
                print("\(state.currentStep)")
                return .none
                
            case .tappedBackButton:
                switch state.currentStep {
                case .nickname,
                        .finish:
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
                    state.birth = ["", "", ""]
                    state.subRegion = nil
                    state.infoError = true
                    state.currentStep = .introduce
                case .introduce:
                    state.introduceText = ""
                    state.introduceError = true
                    return .send(.signup)
                case .finish:
                    break
                }
                return .none
            case .infoStepViewOnAppear:
                return .run { send in
                    do {
                        let list = try await authService.getRegionList().toEntity()
                        await send(.setRegion(list))
                    } catch {
                        print("error: \(error.localizedDescription)")
                    }
                }
            case .checkNickname:
                if state.nicknameErrorState == .noError {
                    return .run { [state] send in
                        do {
                            let isDuplicated = try await authService.nicknameDuplicateCheck(userName: state.nicknameText)
                            
                            if isDuplicated {
                                await send(.setNicknameError(.duplicateNicknameError))
                            } else {
                                await send(.setNicknameError(.avaliableNickname))
                            }
                        }
                    }
                }
                
                if state.nicknameErrorState == .avaliableNickname {
                    state.nicknameError = false
                }
                return .none
            case .setNicknameError(let error):
                state.nicknameErrorState = error
                return .none
            case .setRegion(let list):
                state.regionList = list
                return .none
            case .signup:
                return .run { [state] send in
                    var birthString = ""
                    if !state.birth[0].isEmpty {
                        birthString = state.birth[0] + "-" + state.birth[1] + "-" + state.birth[2]
                    }
                    
                    do {
                        guard let token = authenticationManager.socialToken
                        else { return }
                        
                        let user = try await authService.signup(
                            platform: authenticationManager.socialType.rawValue,
                            userName: state.nicknameText,
                            birth: birthString,
                            regionId: state.subRegion?.id ?? nil,
                            introduction: state.introduceText,
                            token: token
                        )
                        
                        AuthenticationManager.shared.setAuthenticationState()
                        
                        await send(.setUserNickname(user))
                    } catch {
                        await send(.error(error))
                    }
                }
            case .setUserNickname(let nickname):
                state.userNickname = nickname
                state.currentStep = .finish
                return .none
            case .error(let error):
                // 토스트 에러
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

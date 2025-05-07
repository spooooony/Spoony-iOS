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
        
        var birth: [String] = ["", "", ""]
        var region: LocationType = .seoul
        var subRegion: SubLocationType?
        var infoError: Bool = true
        
        var introduceText: String = ""
        var introduceError: Bool = true
        
        var user: OnboardingUserEntity = .init(
            userName: "",
            region: nil,
            introduction: nil,
            birth: nil
        )
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case tappedNextButton
        case tappedBackButton
        case tappedSkipButton
        
        case checkNickname
        case signup
        case setUser(OnboardingUserEntity)
        
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
                    state.currentStep = .introduce
                case .introduce:
                    return .send(.signup)
                case .finish:
                    break
                }
                return .none
            case .checkNickname:
                if state.nicknameErrorState == .noError {
                    // 닉네임 체크 api
                    state.nicknameErrorState = .avaliableNickname
                }
                
                if state.nicknameErrorState == .avaliableNickname {
                    state.nicknameError = false
                }
                return .none
            case .signup:
                // 추후 고차함수로 수정
                let birthString = state.birth[0] + state.birth[1] + state.birth[2]
                return .run { [state] send in
                    do {
                        let user = try await authService.signup(
                            platform: authenticationManager.socialType.rawValue,
                            userName: state.nicknameText,
                            birth: birthString,
                            // 임시
                            regionId: 0,
                            introduction: state.introduceText
                        )
                        await send(.setUser(user))
                    } catch {
                        await send(.error(error))
                    }
                }
            case .setUser(let user):
                state.user = user
                state.currentStep = .finish
                return .none
            case .error(let error):
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

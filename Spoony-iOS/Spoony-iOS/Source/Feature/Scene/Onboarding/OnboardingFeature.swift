//
//  OnboardingFeature.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/13/25.
//

import SwiftUI

import ComposableArchitecture
import Mixpanel

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
        
        var regionList: [Region] = []
        
        var birth: [String] = ["", "", ""]
        var region: LocationType = .seoul
        var subRegion: Region?
        var infoError: Bool = true
        
        var introduceText: String = ""
        var introduceError: Bool = true
        
        var userNickname: String = ""
        
        var isLoading: Bool = false
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
        
        // MARK: - Route Action: 화면 전환 이벤트를 상위 Reducer에 전달 시 사용
        case delegate(Delegate)
        enum Delegate {
            case routeToTabCoordinatorScreen
            case presentToast(ToastType)
        }
    }
    
    private let authenticationManager = AuthenticationManager.shared
    @Dependency(\.authService) var authService: AuthProtocol
    @Dependency(\.fetchRegionUseCase) var fetchRegionUseCase: FetchRegionUseCaseProtocol
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .tappedNextButton:
                switch state.currentStep {
                case .nickname:
                    state.currentStep = .information
                    Mixpanel.mainInstance().track(event: OnboardingEvents.Name.onboarding1Completed)
                case .information:
                    state.currentStep = .introduce
                    let property = OnboardingEvents.Onboarding1CompletedProperty(
                        birthdateEntered: !state.birth[0].isEmpty,
                        activeRegionEntered: state.subRegion != nil
                    )
                    
                    Mixpanel.mainInstance().track(
                        event: OnboardingEvents.Name.onboarding2Completed,
                        properties: property.dictionary
                    )
                case .introduce:
                    let property = OnboardingEvents.Onboarding3CompletedProperty(
                        bioLength: state.introduceText.count
                    )
                    
                    Mixpanel.mainInstance().track(
                        event: OnboardingEvents.Name.onboarding3Completed,
                        properties: property.dictionary
                    )
                    
                    return .send(.signup)
                case .finish:
                    UserManager.shared.completeOnboarding()
                    return .send(.delegate(.routeToTabCoordinatorScreen))
                }
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
                    
                    Mixpanel.mainInstance().track(event: OnboardingEvents.Name.onboarding2Skiped)
                case .introduce:
                    state.introduceText = ""
                    state.introduceError = true
                    
                    Mixpanel.mainInstance().track(event: OnboardingEvents.Name.onboarding3Skiped)
                    return .send(.signup)
                case .finish:
                    break
                }
                return .none
                
            case .infoStepViewOnAppear:
                return .run { send in
                    do {
                        let list = try await fetchRegionUseCase.execute()
                        await send(.setRegion(list))
                    } catch {
                        await send(.error(SNError.networkFail))
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
                        } catch {
                            await send(.error(SNError.networkFail))
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
                state.isLoading = true
                return .run { [state] send in
                    var birthString = ""
                    if !state.birth[0].isEmpty {
                        birthString = state.birth[0] + "-" + state.birth[1] + "-" + state.birth[2]
                    }
                    
                    do {
                        guard let token = authenticationManager.socialToken
                        else { return }
                        let user: String
                        if let code = authenticationManager.appleCode {
                            user = try await authService.signup(
                                platform: authenticationManager.socialType.rawValue,
                                userName: state.nicknameText,
                                birth: birthString,
                                regionId: state.subRegion?.id ?? nil,
                                introduction: state.introduceText,
                                token: token,
                                code: code
                            )
                        } else {
                            user = try await authService.signup(
                                platform: authenticationManager.socialType.rawValue,
                                userName: state.nicknameText,
                                birth: birthString,
                                regionId: state.subRegion?.id ?? nil,
                                introduction: state.introduceText,
                                token: token,
                                code: nil
                            )
                        }
                        
                        await send(.setUserNickname(user))
                    } catch {
                        await send(.error(SNError.networkFail))
                    }
                }
                
            case .setUserNickname(let nickname):
                state.isLoading = false
                state.userNickname = nickname
                state.currentStep = .finish
                UserManager.shared.hasCompletedOnboarding = true
                return .none
                
            case .error:
                state.isLoading = false
                return .send(.delegate(.presentToast(.serverError)))
                
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
                
            case .delegate:
                return .none
            }
        }
    }
}

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
        case viewAction(ViewAction)
        case privateAction(PrivateAction)
        case delegate(Delegate)
        case binding(BindingAction<State>)
    }
    
    enum ViewAction {
        case infoStepViewOnAppear
        case tappedNextButton
        case tappedBackButton
        case tappedSkipButton
        case checkNickname
    }
    
    enum PrivateAction {
        case signup
        
        case setUserNickname(String)
        case setNicknameError(NicknameTextFieldErrorState)
        case setRegion([Region])
        
        case error(Error)
    }
    
    enum Delegate: Equatable {
        case routeToTabCoordinatorScreen
        case presentToast(ToastType)
    }

    @Dependency(\.fetchRegionUseCase) var fetchRegionUseCase: FetchRegionUseCaseProtocol
    @Dependency(\.checkNicknameDuplicateUseCase) var chekcNicknameDuplicateUseCase: CheckNicknameDuplicateUseCaseProtocol
    @Dependency(\.signUpUseCase) var signUpUseCase: SignUpUseCaseProtocol
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            // MARK: - viewAction
            case .viewAction(.tappedNextButton):
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
                    
                    return .send(.privateAction(.signup))
                case .finish:
                    return .send(.delegate(.routeToTabCoordinatorScreen))
                }
                return .none
                
            case .viewAction(.tappedBackButton):
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
                
            case .viewAction(.tappedSkipButton):
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
                    return .send(.privateAction(.signup))
                case .finish:
                    break
                }
                return .none
                
            case .viewAction(.infoStepViewOnAppear):
                return .run { send in
                    do {
                        let list = try await fetchRegionUseCase.execute()
                        await send(.privateAction(.setRegion(list)))
                    } catch {
                        await send(.privateAction(.error(SNError.networkFail)))
                    }
                }
                
            case .viewAction(.checkNickname):
                if state.nicknameErrorState == .noError {
                    return .run { [state] send in
                        do {
                            let isDuplicated = try await chekcNicknameDuplicateUseCase.execute(nickname: state.nicknameText)
                            
                            if isDuplicated {
                                await send(.privateAction(.setNicknameError(.duplicateNicknameError)))
                            } else {
                                await send(.privateAction(.setNicknameError(.avaliableNickname)))
                            }
                        } catch {
                            await send(.privateAction(.error(SNError.networkFail)))
                        }
                    }
                }
                
                if state.nicknameErrorState == .avaliableNickname {
                    state.nicknameError = false
                }
                return .none
                
            // MARK: - privateAction
            case .privateAction(.setNicknameError(let error)):
                state.nicknameErrorState = error
                return .none
                
            case .privateAction(.setRegion(let list)):
                state.regionList = list
                return .none
                
            case .privateAction(.signup):
                state.isLoading = true
                return .run { [state] send in
                    var birthString = ""
                    if !state.birth[0].isEmpty {
                        birthString = state.birth[0] + "-" + state.birth[1] + "-" + state.birth[2]
                    }
                    
                    do {
                        let signUpInfo = SignUpEntity(
                            userName: state.nicknameText,
                            birth: birthString,
                            regionId: state.subRegion?.id ?? nil,
                            introduction: state.introduceText
                        )
                        let nickname = try await signUpUseCase.execute(info: signUpInfo)

                        Mixpanel.mainInstance().identify(distinctId: String(UserManager.shared.userId ?? 0))
                        
                        await send(.privateAction(.setUserNickname(nickname)))
                    } catch {
                        await send(.privateAction(.error(SNError.networkFail)))
                    }
                }
                
            case .privateAction(.setUserNickname(let nickname)):
                state.isLoading = false
                state.userNickname = nickname
                state.currentStep = .finish
                return .none
                
            case .privateAction(.error):
                state.isLoading = false
                return .send(.delegate(.presentToast(.serverError)))
                
            // MARK: - Binding
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
                
            default:
                return .none
            }
        }
    }
}

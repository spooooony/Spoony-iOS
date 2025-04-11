//
//  RegisterFeature.swift
//  Spoony-iOS
//
//  Created by 최안용 on 3/21/25.
//

import ComposableArchitecture

@Reducer
struct RegisterFeature {
    @ObservableState
    struct State: Equatable {
        static let initialState = State(
            infoStepState: .initialState,
            reviewStepState: .initialState
        )
        
        var currentStep: RegisterStep = .start
        var isLoading: Bool = false
        var isRegistrationSuccess: Bool = false
        var infoStepState: InfoStepFeature.State
        var reviewStepState: ReviewStepFeature.State
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case updateIsLoading(Bool)
        case updateStep(RegisterStep)
        case resetState
        case registrationSuccessful
        case onDisappear
        
        // MARK: - Child Action
        case infoStepAction(InfoStepFeature.Action)
        case reviewStepAction(ReviewStepFeature.Action)
        
        // MARK: - TabCoordinator Action
        case presentPopup
        case presentToast(message: String)
    }
        
    @Dependency(\.registerService) var network: RegisterServiceType
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        
        Scope(state: \.infoStepState, action: \.infoStepAction) {
            InfoStepFeature()
        }
        
        Scope(state: \.reviewStepState, action: \.reviewStepAction) {
            ReviewStepFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .updateIsLoading(let isLoading):
                state.isLoading = isLoading
                return .none
            case .updateStep(let step):
                state.currentStep = step
                return .none
            case .infoStepAction(.didTapNextButton):
                state.currentStep = .middle
                return .none
            case let .infoStepAction(.presentToast(message)):
                return .send(.presentToast(message: message))
            case .reviewStepAction(.didTapNextButton):
                state.currentStep = .end
                
                guard let selectedPlace = state.infoStepState.selectedPlace,
                      let selectedCategory = state.infoStepState.selectedCategory.first else {
                    return .none
                }
                
                let request = RegisterPostRequest(
                    userId: Config.userId,
                    title: state.reviewStepState.simpleText,
                    description: state.reviewStepState.detailText,
                    placeName: selectedPlace.placeName,
                    placeAddress: selectedPlace.placeAddress,
                    placeRoadAddress: selectedPlace.placeRoadAddress,
                    latitude: selectedPlace.latitude,
                    longitude: selectedPlace.longitude,
                    categoryId: selectedCategory.id,
                    menuList: state.infoStepState.recommendTexts.map { $0.text }
                )
                
                let images = state.reviewStepState.uploadImages.map { $0.imageData }
                
                state.isLoading = true
                
                return .run { [request, images] send in
                    guard let success = try? await network.registerPost(
                        request: request,
                        imagesData: images
                    ) else {
                        await send(.updateIsLoading(false))
                        return
                    }
                    
                    await send(.updateIsLoading(false))
                    
                    if success {
                        await send(.registrationSuccessful)
                    } else {
                        await send(.presentToast(message: "네트워크 오류!"))
                    }
                }
            case .reviewStepAction(.movePreviousView):
                state.currentStep = .start
                return .none
            case .resetState:
                state.currentStep = .start
                state.isRegistrationSuccess = false
                var infoStepNewState: InfoStepFeature.State = .initialState
                infoStepNewState.isToolTipPresented = false
                state.infoStepState = infoStepNewState
                state.reviewStepState = .initialState
                return .none
            case .registrationSuccessful:
                state.currentStep = .end
                state.isRegistrationSuccess = true
                return .send(.presentPopup)
            case .onDisappear:
                if state.isRegistrationSuccess {
                    return .send(.resetState)
                } else {
                    return .none
                }
            default: return .none
            }
        }
    }
}

enum RegisterServiceKey: DependencyKey {
    static let liveValue: RegisterServiceType = RegisterService()
}

extension DependencyValues {
    var registerService: RegisterServiceType {
        get { self[RegisterServiceKey.self] }
        set { self[RegisterServiceKey.self] = newValue }
    }
}

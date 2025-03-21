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
        
        var infoStepState: InfoStepFeature.State
        var reviewStepState: ReviewStepFeature.State
        var toast: Toast?
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case updateIsLoading(Bool)
        case updateStep(RegisterStep)
        case infoStepAction(InfoStepFeature.Action)
        case reviewStepAction(ReviewStepFeature.Action)
        case updateToast(message: String)
        case resetState
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
                        await send(.resetState)
                    } else {
                        await send(.updateToast(message: "네트워크 오류!"))
                    }
                }
            case .reviewStepAction(.movePreviousView):
                state.currentStep = .start
                return .none
            case .updateToast(let message):
                state.toast = .init(style: .gray, message: message, yOffset: 558.adjustedH)
                return .none
            case .resetState:
                var newState = State.initialState
                newState.infoStepState.isToolTipPresented = false
                state = newState
                return .none
                
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

//
//  RegisterFeature.swift
//  Spoony-iOS
//
//  Created by 최안용 on 3/21/25.
//

import ComposableArchitecture
import Foundation

@Reducer
struct RegisterFeature {
    @ObservableState
    struct State: Equatable {
        static let initialState = State(
            infoStepState: .initialState,
            reviewStepState: .initialState
        )
        
        static let editState = State(
            infoStepState: .editState,
            reviewStepState: .editState
        )
        
        var currentStep: RegisterStep = .start
        var isLoading: Bool = false
        var isRegistrationSuccess: Bool = false
        var infoStepState: InfoStepFeature.State
        var reviewStepState: ReviewStepFeature.State
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
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
        
        case routeToPreviousScreen
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
            case .onAppear:
                if state.infoStepState.isEditMode {
                    // TODO: - 게시물 정보 API 호출
                    state.infoStepState.selectedCategory.append(
                        .init(
                            image: "https://spoony-storage.s3.ap-northeast-2.amazonaws.com/category/icons/korean_black.png",
                            selectedImage: "https://spoony-storage.s3.ap-northeast-2.amazonaws.com/category/icons/korean_white.png",
                            title: "한식",
                            id: 3
                        )
                    )
                    
                    state.infoStepState.recommendTexts = [RecommendText(text: "아메리카노")]
                    state.infoStepState.selectedPlace = .init(
                        placeName: "스타벅스 한국프레스센터점",
                        placeAddress: "서울특별시 중구 태평로1가 25",
                        placeRoadAddress: "모름",
                        latitude: 37.5672475,
                        longitude: 126.9780493
                    )
                    state.infoStepState.satisfaction = 90.0
                    state.reviewStepState.detailText = "한 달에 5번은 먹는 마라탕 집이에요. 마라 향 센 걸 잘 못 먹는 사람들한테 추천해용 친구, 가족 모두한테 소개해 줬는데 다들 좋아해요!"
                    state.reviewStepState.uploadImages.append(UploadImage(image: ImageType(.imgMockGodeung), imageData: Data()))
                    
                    state.reviewStepState.selectableCount = 4
                }
                return .none
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
                
                // TODO: - 수정 등록 분기
                let request = RegisterPostRequest(
                    userId: Config.userId,
                    title: "",
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
                
                if state.reviewStepState.isEditMode {
                    // TODO: - 디테일 화면으로 이동
                    return .send(.routeToPreviousScreen)
                } else {
                    return .send(.presentPopup)
                }
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

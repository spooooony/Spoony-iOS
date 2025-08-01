//
//  RegisterFeature.swift
//  Spoony-iOS
//
//  Created by 최안용 on 3/21/25.
//

import Foundation

import ComposableArchitecture
import Mixpanel

@Reducer
struct RegisterFeature {
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
                       
        var postId: Int?
        var userId: Int?
        var savedCount: Int?
        var currentStep: RegisterStep = .start
        var isLoading: Bool = false
        var isPosting: Bool = false
        var isRegistrationSuccess: Bool = false
        var infoStepState: InfoStepFeature.State
        var reviewStepState: ReviewStepFeature.State
        
        init(postId: Int) {
            self.postId = postId
            infoStepState = .editState
            reviewStepState = .editState
        }
        
        init() {
            infoStepState = .initialState
            reviewStepState = .initialState
        }
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case updateIsLoading(Bool)
        case updateIsPosting(Bool)
        case updateStep(RegisterStep)
        case registrationSuccessful
        case onDisappear
        case registerPostRequest(_ selectedPlace: PlaceInfo, _ selectedCategory: CategoryChip)
        case editPostRequest(_ selectedCategory: CategoryChip)
        case reviewInfoResponse(_ response: ReviewInfo)
        
        // MARK: - Child Action
        case infoStepAction(InfoStepFeature.Action)
        case reviewStepAction(ReviewStepFeature.Action)
        
        // MARK: - TabCoordinator Action
        case presentPopup
        case presentToast(message: String)
        
        case routeToPostScreen(Int)
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
                    guard let postId = state.postId else { return .none }
                    
                    state.isLoading = true
                    
                    return .run { [postId] send in
                        do {
                            let reviewInfo = try await network.getReviewInfo(postId: postId).toModel()
                            await send(.reviewInfoResponse(reviewInfo))
                        } catch {
                            await send(.infoStepAction(.updateIsLoadError(true)))
                            await send(.updateIsLoading(false))
                            await send(.presentToast(message: "서버에 연결할 수 없습니다.\n 잠시 후 다시 시도해 주세요."))
                        }
                    }
                }
                return .none
            case .reviewInfoResponse(let reviewInfo):
                state.infoStepState.selectedPlace = PlaceInfo(
                    placeName: reviewInfo.placeName,
                    placeAddress: "",
                    placeRoadAddress: reviewInfo.placeAddress,
                    latitude: 0.0,
                    longitude: 0.0
                )
                
                state.infoStepState.selectedCategoryId = reviewInfo.selectedCategoryId
                state.infoStepState.recommendTexts = reviewInfo.menuList.map { RecommendText(text: $0) }
                state.infoStepState.satisfaction = reviewInfo.value
                state.reviewStepState.detailText = reviewInfo.description
                state.reviewStepState.weakPointText = reviewInfo.cons
                state.reviewStepState.uploadImages = reviewInfo.uploadImages
                state.reviewStepState.selectableCount = 5 - reviewInfo.uploadImages.count
                state.userId = reviewInfo.userId
                state.savedCount = reviewInfo.savedCount
                state.isLoading = false
                return .send(.infoStepAction(.loadSelectedCategory))
            case .updateIsLoading(let isLoading):
                state.isLoading = isLoading
                return .none
            case .updateIsPosting(let isPosting):
                state.isPosting = isPosting
                return .none
            case .updateStep(let step):
                state.currentStep = step
                return .none
            case .infoStepAction(.didTapNextButton):
                state.currentStep = .end
                return .none
            case let .infoStepAction(.presentToast(message)):
                return .send(.presentToast(message: message))
            case .reviewStepAction(.didTapNextButton):                
                guard let selectedPlace = state.infoStepState.selectedPlace,
                      let selectedCategory = state.infoStepState.selectedCategory.first else {
                    return .none
                }
                                
                if state.infoStepState.isEditMode {
                    return .send(.editPostRequest(selectedCategory))
                } else {
                    return .send(.registerPostRequest(selectedPlace, selectedCategory))
                }
            case .reviewStepAction(.movePreviousView):
                state.currentStep = .start
                return .none

            case let .registerPostRequest(selectedPlace, selectedCategory):
                let trimmed = state.reviewStepState.weakPointText.trimmingCharacters(in: .whitespacesAndNewlines)
                let cons = trimmed.isEmpty ? nil : trimmed
                
                let request = RegisterPostRequest(
                    title: "",
                    description: state.reviewStepState.detailText,
                    value: state.infoStepState.satisfaction,
                    cons: cons,
                    placeName: selectedPlace.placeName,
                    placeAddress: selectedPlace.placeAddress,
                    placeRoadAddress: selectedPlace.placeRoadAddress,
                    latitude: selectedPlace.latitude,
                    longitude: selectedPlace.longitude,
                    categoryId: selectedCategory.id,
                    menuList: state.infoStepState.recommendTexts.map { $0.text }
                )
                
                let images = state.reviewStepState.uploadImages.compactMap { $0.imageData }
                
                state.isPosting = true
                
                return .run { [request, images] send in
                    guard let success = try? await network.registerPost(
                        request: request,
                        imagesData: images
                    ) else {
                        await send(.updateIsPosting(false))
                        await send(.presentToast(message: "서버에 연결할 수 없습니다.\n 잠시 후 다시 시도해 주세요."))
                        return
                    }
                    
                    if success {
                        await send(.registrationSuccessful)
                    } else {
                        await send(.presentToast(message: "서버에 연결할 수 없습니다.\n 잠시 후 다시 시도해 주세요."))
                    }
                }
            case let .editPostRequest(selectedCategory):
                guard let postId = state.postId else { return .none }
                let request = EditPostRequest(
                    postId: postId,
                    description: state.reviewStepState.detailText,
                    value: state.infoStepState.satisfaction,
                    cons: state.reviewStepState.weakPointText,
                    categoryId: selectedCategory.id,
                    menuList: state.infoStepState.recommendTexts.map { $0.text },
                    deleteImageUrlList: state.reviewStepState.deleteImagesUrl
                )
                
                let images = state.reviewStepState.uploadImages.compactMap { $0.imageData }
                
                state.isPosting = true
                
                return .run { [request, images] send in
                    guard let success = try? await network.editPost(
                        request: request,
                        imagesData: images
                    ) else {
                        await send(.updateIsPosting(false))
                        await send(.presentToast(message: "서버에 연결할 수 없습니다.\n 잠시 후 다시 시도해 주세요."))
                        return
                    }
                    
                    if success {
                        await send(.registrationSuccessful)
                    } else {
                        await send(.updateIsPosting(false))
                        await send(.presentToast(message: "서버에 연결할 수 없습니다.\n 잠시 후 다시 시도해 주세요."))
                    }
                }
            case .registrationSuccessful:
                state.currentStep = .end
                state.isRegistrationSuccess = true
                
                if state.reviewStepState.isEditMode {
                    guard let postId = state.postId else {
                        // 여기 뭐로 분기하지
                        return .send(.routeToPreviousScreen)
                    }
                    
                    guard let userId = state.userId,
                          let savedCount = state.savedCount,
                          let placeName = state.infoStepState.selectedPlace?.placeName,
                          let category = state.infoStepState.selectedCategory.first?.title else {
                        return .none
                    }
                    
                    let property = CommonEvents.ReviewEditProperty(
                        reviewId: postId,
                        authorUserId: userId,
                        placeId: 1,
                        placeName: placeName,
                        category: category,
                        menuCount: state.infoStepState.recommendTexts.count,
                        satisfaction: state.infoStepState.satisfaction,
                        reviewLength: state.reviewStepState.detailText.count,
                        photoCount: state.reviewStepState.uploadImages.count,
                        hasDisappointment: !state.reviewStepState.weakPointText.isEmpty,
                        savedCount: savedCount,
                        entryPoint: .review
                        
                    )
                    
                    Mixpanel.mainInstance().track(
                        event: CommonEvents.Name.reviewEdited,
                        properties: property.dictionary
                    )
                    
                    return .send(.routeToPostScreen(postId))
                } else {
                    return .send(.presentPopup)
                }
            default: return .none
            }
        }
    }
}

//
//  ReviewStepFeature.swift
//  Spoony-iOS
//
//  Created by 최안용 on 3/21/25.
//

import Foundation

import ComposableArchitecture
import Mixpanel

@Reducer
struct ReviewStepFeature {
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
        static var editState: State {
            var state = State()
            state.isEditMode = true
            state.isDisableNextButton = false
            state.isDetailTextError = false
            state.uploadImageErrorState = .noError
            return state
        }
        
        var isEditMode: Bool = false
        
        // MARK: - 리뷰 관련 property
        var detailText: String = ""
        var isDetailTextError: Bool = true
        
        // MARK: - 이미지 업로드 관련 property
        var selectableCount = 5
        var pickerItems: [PhotoPickerType] = []
        var uploadImages: [UploadImage] = []
        var uploadImageErrorState: UploadImageErrorState = .initial
        var deleteImagesUrl: [String] = []
        
        // MARK: - 아쉬운 점 관련 property
        var weakPointText: String = ""
        var isWeakPointTextError: Bool  = false
        
        var isDisableNextButton: Bool = true
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case didTapNextButton
        case movePreviousView
        case didTapPhotoDeleteIcon(UploadImage)
        case updateUploadImages([UploadImage])
        case removePickerItems
        case validateNextButton
    }
    
    @Dependency(\.registerService) var network: RegisterServiceType
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding(\.pickerItems):
                if state.pickerItems.count > state.selectableCount {
                    state.pickerItems = Array(state.pickerItems.prefix(state.selectableCount))
                    state.selectableCount = 0
                } else {
                    state.selectableCount -= state.pickerItems.count
                }
                
                let pickerItems = state.pickerItems
                return .run { [pickerItems] send in
                    let uploadImages = await withTaskGroup(of: UploadImage?.self) { group in
                        for item in pickerItems {
                            group.addTask {
                                await transferImage(item)
                            }
                        }
                        
                        return await group
                            .reduce(into: [UploadImage?](), { $0.append($1) })
                            .compactMap { $0 }
                    }
                    
                    await send(.updateUploadImages(uploadImages))
                    await send(.removePickerItems)
                }
            case .binding(\.isWeakPointTextError), .binding(\.isDetailTextError):
                return .send(.validateNextButton)
            case .didTapPhotoDeleteIcon(let image):
                if let index = state.uploadImages.firstIndex(where: { $0.id == image.id }) {
                    state.uploadImages.remove(at: index)
                    state.selectableCount += 1
                    
                    if let url = image.url {
                        state.deleteImagesUrl.append(url)
                    }
                    
                    if state.uploadImages.isEmpty {
                        state.uploadImageErrorState = .error
                    }
                }
                
                return .send(.validateNextButton)
            case .updateUploadImages(let images):
                state.uploadImages.append(contentsOf: images)
                return .none
            case .removePickerItems:
                state.uploadImageErrorState = .noError
                state.pickerItems = []
                return .send(.validateNextButton)
            case .validateNextButton:
                let imageError = [.error, .initial].contains(state.uploadImageErrorState)
                state.isDisableNextButton = imageError || state.isWeakPointTextError || state.isDetailTextError
                return .none
            case .didTapNextButton:
                if !state.isEditMode {
                    let property = RegisterEvents.Review2Property(
                        reviewLength: state.detailText.count,
                        photoCount: state.uploadImages.count,
                        hasDisappointment: !state.weakPointText.isEmpty
                    )
                    
                    Mixpanel.mainInstance().track(
                        event: RegisterEvents.Name.reivew2Complete,
                        properties: property.dictionary
                    )
                }
                
                return .none
                
            default: return .none
            }
        }
    }
}

extension ReviewStepFeature {
    private func transferImage(_ item: PhotoPickerType) async -> UploadImage? {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let jpegData = UIImageType(data: data)?.downscaleTOjpegData(maxBytes: 1_000_000),
              let image = UIImageType(data: jpegData) else { return nil }
        
        let uploadImage = UploadImage(image: ImageType(uiImage: image), imageData: jpegData)
        
        return uploadImage
    }
}

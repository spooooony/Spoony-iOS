//
//  ReviewStepFeature.swift
//  Spoony-iOS
//
//  Created by 최안용 on 3/21/25.
//

import Foundation

import ComposableArchitecture

@Reducer
struct ReviewStepFeature {
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
        // MARK: - 리뷰 관련 property
        var simpleText: String = ""
        var detailText: String = ""
        var isSimpleTextError: Bool = true
        var isDetailTextError: Bool = true
        
        // MARK: - 이미지 업로드 관련 property
        var selectableCount = 5
        var pickerItems: [PhotoPickerType] = []
        var uploadImages: [UploadImage] = []
        var uploadImageErrorState: UploadImageErrorState = .initial
        
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
            case .binding(\.isSimpleTextError), .binding(\.isDetailTextError):
                return .send(.validateNextButton)
            case .didTapPhotoDeleteIcon(let image):
                if let index = state.uploadImages.firstIndex(where: { $0.id == image.id }) {
                    state.uploadImages.remove(at: index)
                    state.selectableCount += 1
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
                state.isDisableNextButton = imageError || state.isSimpleTextError || state.isDetailTextError
                return .none
            default: return .none
            }
        }
    }
}

extension ReviewStepFeature {
    private func transferImage(_ item: PhotoPickerType) async -> UploadImage? {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let jpegData = UIImageType(data: data)?.jpegData(compressionQuality: 0.1),
              let image = UIImageType(data: jpegData) else { return nil }
        
        let uploadImage = UploadImage(image: ImageType(uiImage: image), imageData: jpegData)
        return uploadImage
    }
}

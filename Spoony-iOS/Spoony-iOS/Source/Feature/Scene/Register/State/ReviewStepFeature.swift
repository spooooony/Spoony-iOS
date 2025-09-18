//
//  ReviewStepFeature.swift
//  Spoony-iOS
//
//  Created by 최안용 on 3/21/25.
//

import Foundation
import PhotosUI
import SwiftUI

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
        var pickerItems: [PhotosPickerItem] = []
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
        case imageLoadFaied
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
                    let uploadImages = await withTaskGroup(of: (Int, UploadImage?).self) { group in
                        for (index, item) in pickerItems.enumerated() {
                            group.addTask {
                                let image = await transferImage(item)
                                return (index, image)
                            }
                        }
                        
                        var results: [(Int, UploadImage?)] = []
                        
                        for await result in group {
                            if let image = result.1 {
                                results.append(result)
                            } else {
                                await send(.imageLoadFaied)
                            }
                        }
                        
                        return results
                            .sorted { $0.0 < $1.0 }
                            .compactMap { $0.1 }
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
                
            case .imageLoadFaied:
                state.selectableCount += 1
                return .none
                
            default: return .none
            }
        }
    }
}

extension ReviewStepFeature {
    private func transferImage(_ item: PhotosPickerItem) async -> UploadImage? {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let jpegData = UIImage(data: data)?.downscaleTOjpegData(maxBytes: 1_000_000),
              let image = UIImage(data: jpegData) else { return nil }
        
        let uploadImage = UploadImage(image: Image(uiImage: image), imageData: jpegData)
        
        return uploadImage
    }
}

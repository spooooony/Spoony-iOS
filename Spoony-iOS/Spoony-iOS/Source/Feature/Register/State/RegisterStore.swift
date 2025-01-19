//
//  RegisterStore.swift
//  Spoony-iOS
//
//  Created by 최안용 on 1/16/25.
//

import SwiftUI
import PhotosUI

struct UploadImage: Identifiable {
    let id = UUID()
    let image: Image
}

enum UploadImageErrorState {
    case initial
    case noError
    case error
}

final class RegisterStore: ObservableObject {
    @Published var uploadImageErrorState: UploadImageErrorState = .initial
    @Published var step: RegisterStep = .start
    @Published var disableFirstButton: Bool = true
    @Published var disableSecondButton: Bool = true
    @Published var text: String = ""
    @Published var simpleReview: String = ""
    @Published var detailReview: String = ""
    @Published var isSelected: Bool = false
    @Published var simpleInputError: Bool = true {
        didSet {
            secondButtonInavlid()
        }
    }
    @Published var detailInputError: Bool = true {
        didSet {
            secondButtonInavlid()
        }
    }
    @Published var categorys: [CategoryChip] = CategoryChip.sample()
    @Published var recommendMenu: [String] = [""] {
        didSet {
            firstButtonInvalid()
        }
    }
    @Published var selectedCategory: [CategoryChip] = [] {
        didSet {
            firstButtonInvalid()
        }
    }
    @Published var searchPlaces: [PlaceInfo] = PlaceInfo.sample()
    @Published var selectedPlace: PlaceInfo? {
        didSet {
            firstButtonInvalid()
        }
    }
    
    @MainActor
    @Published var pickerItem: PhotosPickerItem? {
        didSet {
            Task {
                do {
                    guard let data = try await pickerItem?.loadTransferable(type: Data.self),
                          let uiImage = UIImage(data: data) else { return }
                    uploadImages.append(.init(image: Image(uiImage: uiImage)))
                } catch {
                    print("Error loading image: \(error)")
                }
            }
        }
    }
    
    @MainActor
    @Published var uploadImages: [UploadImage] = [] {
        didSet {
            pickerItem = nil
            uploadImageErrorState = .noError
            secondButtonInavlid()
        }
    }

    func firstButtonInvalid() {
        let isRecommendMenuInvalid = recommendMenu.contains { $0.isEmpty }
        
        let isSelectedCategoryInvalid = selectedCategory.isEmpty
        
        let isSelectedPlaceInvalid = selectedPlace == nil
        
        disableFirstButton = isRecommendMenuInvalid || isSelectedCategoryInvalid || isSelectedPlaceInvalid
    }
    
    func secondButtonInavlid() {
        let uploadImageError = uploadImageErrorState == .error
        let isInitial = uploadImageErrorState == .initial
        disableSecondButton = simpleInputError || detailInputError || uploadImageError || isInitial
    }
    
    @MainActor
    func deleteImage(_ image: UploadImage) {
        guard let index = uploadImages.firstIndex(where: { $0.id == image.id }) else { return }
        uploadImages.remove(at: index)
        if uploadImages.isEmpty {
            uploadImageErrorState = .error
            secondButtonInavlid()
        }
    }
    
    func isUploadImageError() -> Bool {
        return uploadImageErrorState == .error
    }
}

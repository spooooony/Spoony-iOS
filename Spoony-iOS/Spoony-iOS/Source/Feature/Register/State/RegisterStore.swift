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
    @Published var toast: Toast? = nil
    @Published var uploadImageErrorState: UploadImageErrorState = .initial
    @Published var step: RegisterStep = .start
    @Published var disableFirstButton: Bool = true
    @Published var disableSecondButton: Bool = true
    @Published var text: String = ""
    @Published var simpleReview: String = ""
    @Published var detailReview: String = ""
    @Published var isSelected: Bool = false
    @Published var isToolTipPresented = true
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
    @Published var pickerItems: [PhotosPickerItem] = [] {
        didSet {
            selectableCount -= pickerItems.count
            Task {
                await loadImage()
            }
        }
    }
    
    @MainActor
    @Published var uploadImages: [UploadImage] = [] {
        didSet {
            pickerItems = []
            uploadImageErrorState = .noError
            secondButtonInavlid()
        }
    }
    
    @Published var selectableCount = 5
    @Published var plusButtonDisabled: Bool = false
    
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
        selectableCount += 1
        if uploadImages.isEmpty {
            uploadImageErrorState = .error
            secondButtonInavlid()
        }
    }
    
    func isUploadImageError() -> Bool {
        return uploadImageErrorState == .error
    }
}

extension RegisterStore {
    @MainActor
    func reset() {
        uploadImageErrorState = .initial
        step = .start
        disableFirstButton = true
        disableSecondButton = true
        text = ""
        simpleReview = ""
        detailReview = ""
        isSelected = false
        simpleInputError = true
        detailInputError = true
        categorys = CategoryChip.sample()
        recommendMenu = [""]
        selectedCategory = []
        searchPlaces = PlaceInfo.sample()
        selectedPlace = nil
        pickerItems = []
        uploadImages = []
    }
    
    private func loadImage() async {
        for item in await pickerItems {
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    let image = Image(uiImage: uiImage)
                    await MainActor.run {
                        self.uploadImages.append(.init(image: image))
                    }
                }
            } catch {
                print("Error loading image: \(error)")
            }
        }
    }
    
    func plusButtonTapped() {
        guard !plusButtonDisabled else { return }
        
        plusButtonDisabled = true

        recommendMenu.append("")
                
        Task {
            do {
                try await Task.sleep(for: .seconds(0.5))
                await MainActor.run {
                    plusButtonDisabled = false
                }
            } catch {
                print("error")
            }
        }
    }
}

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
    let imageData: Data
}

enum UploadImageErrorState {
    case initial
    case noError
    case error
}

enum RegisterInputText {
    case place
    case simple
    case detail
}

enum RegisterCurrentViewType {
    case start
    case middle
}

struct TextList {
    let id = UUID()
    var text = ""
}

final class RegisterStore: ObservableObject {
    @Published private(set) var state: RegisterState = RegisterState()
    
    private let network: RegisterServiceType = RegisterService()
    private let navigationManager: NavigationManager
    
    init(navigationManager: NavigationManager) {
        self.navigationManager = navigationManager
    }
    
    func dispatch(_ intent: RegisterIntent) {
        switch intent {
        case .updateText(let newText, let type):
            switch type {
            case .place:
                state.placeText = newText
            case .simple:
                state.simpleText = newText
            case .detail:
                state.detailText = newText
            }
        case .updateTextList(let newText, let id):
            if let index = state.recommendTexts.firstIndex(where: { $0.id == id }) {
                state.recommendTexts[index].text = newText
                firstButtonInvalid()
            }
        case .didTapButtonIcon(let type):
            switch type {
            case .place:
                state.placeText = ""
                state.isDropDownPresented = false
            case .simple, .detail:
                break
            }
            firstButtonInvalid()
        case .deleteTextList(let text):
            if let index = state.recommendTexts.firstIndex(where: { $0.id == text.id }) {
                state.recommendTexts.remove(at: index)
                firstButtonInvalid()
            }
        case .updateButtonState(let newValue, let type):
            switch type {
            case .start:
                state.isDisableStartButton = newValue
                firstButtonInvalid()
            case .middle:
                state.isDisableMiddleButton = newValue
                secondButtonInavlid()
            }
        case .updateSelectedCategoryChip(let chips):
            state.selectedCategory = chips
            firstButtonInvalid()
        case .didTapPlaceInfoCell(let place):
            checkDuplicatePlace(place)
        case .didTapPlaceInfoCellIcon:
            state.selectedPlace = nil
            firstButtonInvalid()
        case .didTapRecommendPlusButton:
            plusButtonTapped()
            firstButtonInvalid()
        case .didTapNextButton(let type):
            switch type {
            case .start:
                state.registerStep = .middle
            case .middle:
                postReview()
            }
        case .didTapkeyboardEnter:
            searchPlace()
        case .updateToolTipState:
            state.isToolTipPresented = false
        case .didTapBackground(let type):
            switch type {
            case .start:
                state.isDropDownPresented = false
            case .middle:
                break
            }
        case .movePreviousView:
            state.registerStep = .start
        case .updateToast(let toast):
            state.toast = toast
        case .updateTextError(let newValue, let type):
            switch type {
            case .simple:
                state.isSimpleTextError = newValue
            case .detail:
                state.isDetailTextError = newValue
            default: break
            }
            secondButtonInavlid()
        case .updatePickerItems(let items):
            state.pickerItems = items
            Task {
                await loadImage()
                
            }
        case .deleteImage(let image):
            if let index = state.uploadImages.firstIndex(where: { $0.id == image.id }) {
                state.uploadImages.remove(at: index)
                state.selectableCount += 1
                if state.uploadImages.isEmpty {
                    state.uploadImageErrorState = .error
                    secondButtonInavlid()
                }
            }
        case .getCategories:
            fetchCategories()
        case .didTapPhoto(let items):
            validateSelectedPhotoCount(item: items)
        case .updateKeyboardHeight(let height):
            Task {
                await MainActor.run {
                    state.keyboardHeight = height
                }
            }
        }
    }
}

extension RegisterStore {
    private func validateSelectedPhotoCount(item: [PhotosPickerItem]) {
        if item.count > state.selectableCount {
            state.pickerItems = Array(item.prefix(state.selectableCount))
            state.selectableCount = 0
        }
    }
    private func loadImage() async {
        await MainActor.run {
            state.selectableCount -= state.pickerItems.count
        }
        
        if state.selectableCount >= 0 {
            for item in state.pickerItems {
                do {
                    if let data = try await item.loadTransferable(type: Data.self),
                       let jpegData = UIImage(data: data)?.jpegData(compressionQuality: 0.1),
                       let image = UIImage(data: jpegData) {
                        let image = Image(uiImage: image)
                        
                        await MainActor.run {
                            state.uploadImages.append(.init(image: image, imageData: jpegData))
                        }
                    }
                } catch {
                    print("Error loading image: \(error)")
                }
            }
            
            await MainActor.run {
                state.pickerItems = []
                state.uploadImageErrorState = .noError
                secondButtonInavlid()
            }
        }
    }
    
    private func plusButtonTapped() {
        guard !state.isDisablePlusButton else { return }
        
        state.isDisablePlusButton = true
        
        state.recommendTexts.append(.init())
        
        Task {
            do {
                try await Task.sleep(for: .seconds(0.5))
                await MainActor.run {
                    state.isDisablePlusButton = false
                }
            } catch {
                print("error")
            }
        }
    }
    
    private func firstButtonInvalid() {
        let isRecommendMenuInvalid = state.recommendTexts.contains { $0.text.isEmpty }
        
        let isSelectedCategoryInvalid = state.selectedCategory.isEmpty
        
        let isSelectedPlaceInvalid = state.selectedPlace == nil
        
        state.isDisableStartButton = isRecommendMenuInvalid || isSelectedCategoryInvalid || isSelectedPlaceInvalid
    }
    
    private func secondButtonInavlid() {
        let uploadImageError = state.uploadImageErrorState == .error
        let isInitial = state.uploadImageErrorState == .initial
        state.isDisableMiddleButton = state.isSimpleTextError || state.isDetailTextError || uploadImageError || isInitial
    }
    
    private func fetchCategories() {
        Task {
            do {
                let ctegorys = try await network.getRegisterCategories().toModel()
                
                await MainActor.run {
                    state.categorys = ctegorys
                }
            } catch {
                print("error")
            }
        }
    }
    
    private func searchPlace() {
        Task {
            do {
                let places = try await network.searchPlace(query: state.placeText).toModel()
                
                await MainActor.run {
                    state.searchedPlaces = places
                    if places.isEmpty {
                        state.toast = .init(
                            style: .gray,
                            message: "검색 결과가 없어요",
                            yOffset: 558.adjustedH
                        )
                    } else {
                        state.isDropDownPresented = true
                    }
                }
            }
        }
    }
    
    private func checkDuplicatePlace(_ place: PlaceInfo) {
        let request = ValidatePlaceRequest(
            userId: Config.userId,
            latitude: place.latitude,
            longitude: place.longitude
        )
        
        Task {
            do {
                let isDuplicate = try await network.validatePlace(request: request).duplicate
                
                await MainActor.run {
                    if isDuplicate {
                        state.toast = .init(
                            style: .gray,
                            message: "앗! 이미 등록한 맛집이에요",
                            yOffset: 558.adjustedH
                        )
                    } else {
                        state.selectedPlace = place
                        firstButtonInvalid()
                    }
                    state.isDropDownPresented = false
                    state.placeText = ""
                }
            }
        }
    }
    
    private func postReview() {
        guard let selectedPlace = state.selectedPlace,
              let selectedCategory = state.selectedCategory.first else { return }
        let request = RegisterPostRequest(
            userId: Config.userId,
            title: state.simpleText,
            description: state.detailText,
            placeName: selectedPlace.placeName,
            placeAddress: selectedPlace.placeAddress,
            placeRoadAddress: selectedPlace.placeRoadAddress,
            latitude: selectedPlace.latitude,
            longitude: selectedPlace.longitude,
            categoryId: selectedCategory.id,
            menuList: state.recommendTexts.map { $0.text }
        )
        
        Task {
            do {
                await MainActor.run {
                    state.isLoading = true
                }
                let success = try await network.registerPost(
                    request: request,
                    imagesData: state.uploadImages.map {
                        $0.imageData
                    })
                await MainActor.run {
                    if success {
                        state.registerStep = .end
                        state.isLoading = false
                        navigationManager.popup = .registerSuccess(action: {
                            self.navigationManager.selectedTab = .explore
                            self.state = .init()
                            self.state.isToolTipPresented = false
                        })
                    } else {
                        state.isLoading = false
                        print("Error")
                    }
                }
                
            } catch {
                
            }
        }
    }
}

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
            state.selectedPlace = place
            firstButtonInvalid()
            state.isDropDownPresented = false
            state.placeText = ""
            // TODO: 중복 확인 로직
            state.toast = .init(style: .gray, message: "앗! 이미 등록한 맛집이에요", yOffset: 556.adjustedH)
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
                state.registerStep = .end
                navigationManager.popup = .registerSuccess(action: {
                    self.navigationManager.selectedTab = .explore
                    self.state = .init()
                    self.state.isToolTipPresented = false
                })
            }
        case .didTapkeyboardEnter:
            state.isDropDownPresented = true
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
        }
    }
}

extension RegisterStore {
    private func loadImage() async {
        for item in state.pickerItems {
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    let image = Image(uiImage: uiImage)
                    await MainActor.run {
                        state.uploadImages.append(.init(image: image))
                    }
                }
            } catch {
                print("Error loading image: \(error)")
            }
        }
        await MainActor.run {
            state.selectableCount -= state.pickerItems.count
            state.pickerItems = []
            state.uploadImageErrorState = .noError
            secondButtonInavlid()
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
}

//
//  RegisterState.swift
//  Spoony-iOS
//
//  Created by 최안용 on 1/20/25.
//

import SwiftUI
import PhotosUI

struct RegisterState {
    // MARK: - Register
    var registerStep: RegisterStep = .start
    
    // MARK: - InfoStepView
    var placeText: String = ""
    var recommendTexts: [TextList] = [.init()]
    
    var toast: Toast?
    // 나중에 api 연결
    var categorys: [CategoryChip] = CategoryChip.sample()
    var selectedCategory: [CategoryChip] = []
    
    var isDropDownPresented: Bool = false
    var isToolTipPresented: Bool = true
    
    var isDisableStartButton: Bool = true
    var isDisablePlusButton: Bool = false
    
    // MARK: - ReviewStepView
    var simpleText: String = ""
    var detailText: String = ""
    
    var selectableCount = 5
    
    var selectedPlace: PlaceInfo?
    // 나중에 api 연결
    var searchedPlaces: [PlaceInfo] = PlaceInfo.sample()
    var pickerItems: [PhotosPickerItem] = []
    var uploadImages: [UploadImage] = []
    
    var isDisableMiddleButton: Bool = true
    var isSimpleTextError: Bool = true
    var isDetailTextError: Bool = true
    
    var uploadImageErrorState: UploadImageErrorState = .initial
}

//
//  RegisterIntent.swift
//  Spoony-iOS
//
//  Created by 최안용 on 1/20/25.
//

import SwiftUI
import PhotosUI

enum RegisterIntent {
    case updateText(String, RegisterInputText)
    case updateTextList(String, UUID)
    case didTapButtonIcon(RegisterInputText)
    case deleteTextList(TextList)
    case updateButtonState(Bool, RegisterCurrentViewType)
    case updateSelectedCategoryChip([CategoryChip])
    case didTapPlaceInfoCell(PlaceInfo)
    case didTapPlaceInfoCellIcon    
    case didTapRecommendPlusButton
    case didTapNextButton(RegisterCurrentViewType)    
    case didTapkeyboardEnter
    case updateToolTipState
    case didTapBackground(RegisterCurrentViewType)
    case updateToast(Toast?)
    case movePreviousView
    case updateTextError(Bool, RegisterInputText)
    case updatePickerItems([PhotosPickerItem])
    case deleteImage(UploadImage)
}

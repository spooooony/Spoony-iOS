//
//  BottomSheetIntent.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/12/25.
//

enum BottomSheetIntent {
    case show
    case hide
    case drag(translation: CGFloat)
    case endDrag(translation: CGFloat)
    case updateHeight(to: BottomSheetStyle)
} 
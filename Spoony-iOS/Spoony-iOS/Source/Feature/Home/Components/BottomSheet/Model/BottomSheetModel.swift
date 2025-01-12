//
//  BottomSheetModel.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/12/25.
//

struct BottomSheetModel {
    var isPresented: Bool
    var currentHeight: CGFloat
    var dragOffset: CGFloat
    let style: BottomSheetStyle
    
    init(style: BottomSheetStyle) {
        self.style = style
        self.isPresented = false
        self.currentHeight = style.height
        self.dragOffset = 0
    }
} 
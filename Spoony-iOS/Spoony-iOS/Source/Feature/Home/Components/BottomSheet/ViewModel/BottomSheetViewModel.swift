//
//  BottomSheetViewModel.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/12/25.
//

final class BottomSheetViewModel: ObservableObject {
    @Published private(set) var model: BottomSheetModel
    
    init(style: BottomSheetStyle) {
        self.model = BottomSheetModel(style: style)
    }
    
    func trigger(_ intent: BottomSheetIntent) {
        switch intent {
        case .show:
            model.isPresented = true
            
        case .hide:
            model.isPresented = false
            
        case .drag(let translation):
            if model.style == .button {
                if translation > 0 {
                    model.dragOffset = min(translation, 100)
                }
            } else {
                let newHeight = model.currentHeight - translation
                if newHeight >= BottomSheetStyle.minimal.height && 
                   newHeight <= BottomSheetStyle.full.height {
                    model.dragOffset = translation
                }
            }
            
        case .endDrag(let translation):
            if model.style == .button {
                if translation > 30 {
                    model.dragOffset = 0
                    model.isPresented = false
                } else {
                    model.dragOffset = 0
                }
                return
            }
            
            let newHeight = model.currentHeight - translation
            if translation > 0 {
                if newHeight < BottomSheetStyle.minimal.height + 50 {
                    model.isPresented = false
                } else if newHeight < BottomSheetStyle.half.height {
                    model.currentHeight = BottomSheetStyle.minimal.height
                } else if newHeight < BottomSheetStyle.full.height {
                    model.currentHeight = BottomSheetStyle.half.height
                }
            } else {
                if newHeight > BottomSheetStyle.half.height + 50 {
                    model.currentHeight = BottomSheetStyle.full.height
                } else if newHeight > BottomSheetStyle.minimal.height + 50 {
                    model.currentHeight = BottomSheetStyle.half.height
                } else {
                    model.currentHeight = BottomSheetStyle.minimal.height
                }
            }
            model.dragOffset = 0
            
        case .updateHeight(let style):
            model.currentHeight = style.height
        }
    }
} 
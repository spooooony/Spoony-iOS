//
//  InquiryFeature.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/25/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct InquiryFeature {
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
        
        var inquiryText: String = ""
        var isSubmitEnabled: Bool = false
    }
    
    enum Action {
        case routeToPreviousScreen
        case updateInquiryText(String)
        case submitButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .routeToPreviousScreen:
                return .none
                
            case let .updateInquiryText(text):
                state.inquiryText = text
                state.isSubmitEnabled = !text.isEmpty
                return .none
                
            case .submitButtonTapped:
                // 여기에 문의 제출 로직 추가
                return .none
            }
        }
    }
}

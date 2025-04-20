//
//  EditProfileFeature.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/13/25.
//

import SwiftUI

import ComposableArchitecture

@Reducer
struct EditProfileFeature {
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
        
        var selectedImage: UIImage?
        var userNickname: String = ""
        var introduction: String = ""
        var birthDate: [String] = ["", "", ""]
        var selectedLocation: LocationType = .seoul
        var selectedSubLocation: SubLocationType? = .gangnam
        var isNicknameError: Bool = false
        var isDisableRegisterButton: Bool = false
        
        // 나중에 삭제
        var nicknameErrorState: NicknameTextFieldErrorState = .initial
        
        var isPresentProfileBottomSheet: Bool = false
        var isPresentBirthdateBottomSheet: Bool = false
        var isPresentLocationBottomSheet: Bool = false
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case didTabRegisterButton
        case didTabQuesetionButton
        // MARK: - MyPageCoordinator Action
        case routeToPreviousScreen
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding(\.nicknameErrorState):
                if state.nicknameErrorState == .minimumInputError {
                    state.isDisableRegisterButton = true
                } else {
                    state.isDisableRegisterButton = false
                }
                return .none
            case .binding: return .none
            case .onAppear:
                // TODO: - 유저 정보 API 호출
                state.userNickname = "Spoony"
                state.birthDate = ["2000", "01", "01"]
                state.selectedLocation = .seoul
                state.selectedSubLocation = .mapo
                return .none
            case .didTabRegisterButton:
                // TODO: - 저장 API 호출
                print(state)
                return .send(.routeToPreviousScreen)
            case .didTabQuesetionButton:
                state.isPresentProfileBottomSheet = true
                return .none
            case .routeToPreviousScreen:
                return .none
            }
        }
    }
}

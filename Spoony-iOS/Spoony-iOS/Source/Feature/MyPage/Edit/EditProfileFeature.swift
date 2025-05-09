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
        
        var imageLevel: Int = 0
        var selectedImage: UIImage?
        var userNickname: String = ""
        var introduction: String = ""
        var birthDate: [String] = ["", "", ""]
        var selectedLocation: LocationType = .seoul
//        var selectedSubLocation: SubLocationType? = .gangnam
        var selectedSubLocation: Region?
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
        case profileInfoResponse(ProfileInfo)
        
        // MARK: - MyPageCoordinator Action
        case routeToPreviousScreen
    }
    
    @Dependency(\.myPageService) var network: MypageServiceProtocol
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce {
            state,
            action in
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
                return .run { send in
                    do {
                        let profileInfo = try await network.getProfileInfo().toModel()
                        await send(.profileInfoResponse(profileInfo))
                    } catch {
                        print("실패")
                    }
                }
            case .profileInfoResponse(let profileInfo):
                state.userNickname = profileInfo.nickname
                state.birthDate = profileInfo.birthDate
                state.introduction = profileInfo.introduction
                state.selectedLocation = profileInfo.selectedLocation
                state.selectedSubLocation = profileInfo.selectedSubLocation
                state.imageLevel = profileInfo.imageLevel
                
                return .none
            case .didTabRegisterButton:
//                let reqeust = EditProfileRequest(
//                    userName: state.userNickname,
//                    regionId: <#T##Int#>,
//                    introduction: <#T##String#>,
//                    birth: <#T##String#>,
//                    imageLevel: <#T##Int#>
//                )
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

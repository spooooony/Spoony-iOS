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
        
        var isLoading: Bool = false
        var imageLevel: Int = 1
        var profileImages: [ProfileImage] = [
            .init(url: "", imageLevel: 1, unlockCondition: "", isUnlocked: true)
        ]
        var savedNickname: String = ""
        var userNickname: String = ""
        var introduction: String = ""
        var birthDate: [String] = ["", "", ""]
        var selectedLocation: LocationType = .seoul
        var regionList: [Region] = []
        var selectedSubLocation: Region?
        var isNicknameError: Bool = false
        var isDisableRegisterButton: Bool = false
        var isLoadError: Bool = false
        var isChangeNickname: Bool = false
        
        // 나중에 삭제
        var nicknameErrorState: NicknameTextFieldErrorState = .initial
        
        var isPresentProfileBottomSheet: Bool = false
        var isPresentBirthdateBottomSheet: Bool = false
        var isPresentLocationBottomSheet: Bool = false
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case didTapRegisterButton
        case didTapQuesetionButton
        case profileInfoResponse(ProfileInfo)
        case profileImagesResponse([ProfileImage])
        case setNicknameError(NicknameTextFieldErrorState)
        case regionsResponse([Region])
        case didTapProfileImage(ProfileImage)
        case checkNickname
        case updateLoadError
        
        // MARK: - TabRootCoordinator Action
        case routeToPreviousScreen
        case presentToast(message: String)
    }
    
    private enum CancelID {
        case profileLoad
        case editProfile
        case nicknameCheck
    }
    
    @Dependency(\.myPageService) var mypageService: MypageServiceProtocol
    @Dependency(\.authService) var authService: AuthProtocol
    
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
            case .binding(\.userNickname):
                state.isChangeNickname = true
                return .none
                
            case .binding: return .none
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    do {
                        async let profileInfo = mypageService.getProfileInfo().toModel()
                        async let profileImages = mypageService.getProfileImages().toModel()
                        async let regionsResponse = authService.getRegionList().toEntity()
                        
                        let (info, images, regions) = try await (profileInfo, profileImages, regionsResponse)
                        
                        await send(.profileImagesResponse(images))
                        await send(.regionsResponse(regions))
                        await send(.profileInfoResponse(info))
                    } catch {
                        await send(.updateLoadError)
                        await send(.presentToast(message: "서버에 연결할 수 없습니다.\n 잠시 후 다시 시도해 주세요."))
                    }
                }
                .cancellable(id: CancelID.profileLoad, cancelInFlight: true)

            case .profileInfoResponse(let profileInfo):
                state.savedNickname = profileInfo.nickname
                state.userNickname = profileInfo.nickname
                state.birthDate = profileInfo.birthDate
                state.introduction = profileInfo.introduction
                state.selectedLocation = profileInfo.selectedLocation
                state.selectedSubLocation = profileInfo.selectedSubLocation
                state.imageLevel = profileInfo.imageLevel
                state.selectedSubLocation = state.regionList.first(where: { $0.regionName == profileInfo.regionName })
                state.isLoading = false
                
                return .none
                
            case .profileImagesResponse(let profileImages):
                state.profileImages = profileImages
                return .none
                
            case .regionsResponse(let regions):
                state.regionList = regions
                return .none
                
            case .setNicknameError(let error):
                state.nicknameErrorState = error
                if error == .duplicateNicknameError {
                    state.isDisableRegisterButton = true
                }
                
                return .none
                
            case .didTapRegisterButton:
                let reqeust = EditProfileRequest(
                    userName: state.userNickname,
                    regionId: state.selectedSubLocation?.id ?? 1,
                    introduction: state.introduction,
                    birth: state.birthDate.joined(separator: "-"),
                    imageLevel: state.imageLevel
                )
                
                return .run { send in
                    let success = try await mypageService.editProfileInfo(request: reqeust)
                    
                    if success {
                        await send(.routeToPreviousScreen)
                    } else {
                        await send(.presentToast(message: "서버에 연결할 수 없습니다.\n 잠시 후 다시 시도해 주세요."))
                        await send(.routeToPreviousScreen)
                    }
                }
                .cancellable(id: CancelID.editProfile, cancelInFlight: true)
                
            case .checkNickname:
                if state.isChangeNickname {
                    if state.savedNickname == state.userNickname {
                        state.isNicknameError = false
                        state.isDisableRegisterButton = false
                        return .none
                    }
                    
                    if state.nicknameErrorState == .noError {
                        return .run { [state] send in
                            do {
                                let isDuplicated = try await authService.nicknameDuplicateCheck(userName: state.userNickname)
                                
                                if isDuplicated {
                                    await send(.setNicknameError(.duplicateNicknameError))
                                } else {
                                    await send(.setNicknameError(.avaliableNickname))
                                }
                            }
                        }
                        .cancellable(id: CancelID.nicknameCheck, cancelInFlight: true)
                    }
                    
                    if state.nicknameErrorState == .avaliableNickname || state.nicknameErrorState == .initial {
                        state.isNicknameError = false
                        state.isDisableRegisterButton = false
                    } else {
                        state.isDisableRegisterButton = true
                    }
                    
                    state.isChangeNickname = false
                }
                return .none
                
            case .didTapQuesetionButton:
                state.isPresentProfileBottomSheet = true
                return .none
                
            case .didTapProfileImage(let image):
                state.imageLevel = image.imageLevel
                return .none
                
            case .routeToPreviousScreen:
                return .merge(
                    .cancel(id: CancelID.profileLoad),
                    .cancel(id: CancelID.editProfile),
                    .cancel(id: CancelID.nicknameCheck)
                )
                
            case .presentToast:
                state.isLoading = false
                return .none
                
            case .updateLoadError:
                state.isLoadError = true
                state.isDisableRegisterButton = true
                return .none
            }
        }
    }
}

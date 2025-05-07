//
//  InfoStepFeature.swift
//  Spoony-iOS
//
//  Created by 최안용 on 3/21/25.
//

import ComposableArchitecture

@Reducer
struct InfoStepFeature {
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
        static var editState: State {
            var state = State()
            state.isEditMode = true
            state.isDisableNextButton = false
            state.isToolTipPresented = false
            return state
        }
        
        var isEditMode: Bool = false
        
        // MARK: - 카테고리 관련 property
        var selectedCategory: [CategoryChip] = []
        var categories: [CategoryChip] = []

        // MARK: - 검색 관련 property
        var placeText: String = ""
        var searchedPlaces: [PlaceInfo] = []
        var selectedPlace: PlaceInfo?
        var isDropDownPresented: Bool = false
        
        // MARK: - 추천 메뉴 관련 property
        var recommendTexts: [RecommendText] = [.init()]
        var isDisablePlusButton: Bool = false
        
        // MARK: - 만족도 property
        var satisfaction: Double = 50.0
        
        var keyboardHeight: SizeValueType = 0
        var isToolTipPresented: Bool = true
        var isDisableNextButton: Bool = true
    }
    
    enum Action: BindableAction, Equatable {
        case onAppear
        case binding(BindingAction<State>)
        
        // MARK: - 카테고리 관련 이벤트
        case categoryResponse([CategoryChip])
        
        // MARK: - 검색 관련 이벤트
        case didTapSearchDeleteIcon
        case didTapKeyboardEnter
        case searchPlaceResponse([PlaceInfo])
        case didTapPlaceInfoCell(PlaceInfo)
        case didTapPlaceInfoCellIcon
        case updatePlace(PlaceInfo?)
        case didTapNextButton
        
        // MARK: - 추천 메뉴 관련 이벤트
        case didTapRecommendPlusButton
        case didTapRecommendDeleteButton(RecommendText)
        case updatePlusButtonState
        
        case validateNextButton
        case didTapBackground
        case updateKeyboardHeight(SizeValueType)
        case updateToolTipState
        
        // MARK: - TabCoordinator Action
        case presentToast(message: String)
    }
    
    @Dependency(\.registerService) var network: RegisterServiceType
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                if !state.categories.isEmpty {
                    return .none
                } else {
                    return .run { send in
                        do {
                            let categories = try await network.getRegisterCategories().toModel()
                            
                            await send(.categoryResponse(categories))
                        } catch {
                            await send(.presentToast(message: "네트워크 에러!"))
                        }
                    }
                }
            case .binding(\.recommendTexts):
                return .send(.validateNextButton)
            case .binding(\.selectedCategory):
                return .send(.validateNextButton)
            case .binding: return .none
            case .categoryResponse(let value):
                state.categories = value
                return .none
            case .didTapSearchDeleteIcon:
                state.placeText = ""
                return .none
            case .didTapKeyboardEnter:
                let searchText = state.placeText
                
                return .run { [searchText] send in
                    do {
                        let places = try await network.searchPlace(query: searchText).toModel()
                        
                        await send(.searchPlaceResponse(places))
                    } catch {
                        await send(.presentToast(message: "네트워크 에러!"))
                    }
                }
            case .searchPlaceResponse(let places):
                state.isDropDownPresented = !places.isEmpty
                state.searchedPlaces = places
                return places.isEmpty ? .send(.presentToast(message: "검색 결과가 없습니다.")) : .none
            case .didTapPlaceInfoCell(let place):
                let request = ValidatePlaceRequest(
                    userId: Config.userId,
                    latitude: place.latitude,
                    longitude: place.longitude
                )
                
                return .run { [request] send in
                    do {
                        let isDuplicate = try await network.validatePlace(request: request).duplicate
                        
                        if isDuplicate {
                            await send(.updatePlace(nil))
                            await send(.presentToast(message: "앗! 이미 등록한 맛집이에요"))
                        } else {
                            await send(.updatePlace(place))
                        }
                    }
                }
            case .updatePlace(let place):
                state.selectedPlace = place
                state.isDropDownPresented = false
                state.placeText = ""
                
                return .send(.validateNextButton)
            case .didTapPlaceInfoCellIcon:
                state.selectedPlace = nil
                
                return .send(.validateNextButton)
            case .didTapRecommendPlusButton:
                guard !state.isDisablePlusButton else { return .none }
                
                state.isDisablePlusButton = true
                
                state.recommendTexts.append(.init())
                
                return .run { send in
                    await send(.validateNextButton)
                    
                    do {
                        try await Task.sleep(for: .seconds(0.5))
                        
                        await send(.updatePlusButtonState)
                    } catch {
                        await send(.presentToast(message: "뭐지"))
                    }
                }
            case .didTapRecommendDeleteButton(let text):
                if let index = state.recommendTexts.firstIndex(where: { $0.id == text.id }),
                   state.recommendTexts.count != 1 {
                    state.recommendTexts.remove(at: index)
                }
                return .send(.validateNextButton)
            case .updatePlusButtonState:
                state.isDisablePlusButton = false
                return .none
            case .didTapNextButton:
                return .none
            case .validateNextButton:
                let isRecommendMenuInvalid = state.recommendTexts.contains(where: { $0.text.isEmpty })
                let isSelectedCategoryInvalid = state.selectedCategory.isEmpty
                
                let isSelectedPlaceInvalid = state.selectedPlace == nil
                
                state.isDisableNextButton = isRecommendMenuInvalid || isSelectedCategoryInvalid || isSelectedPlaceInvalid
                return .none
            case .didTapBackground:
                state.isDropDownPresented = false
                return .none
            case .updateKeyboardHeight(let height):
                state.keyboardHeight = height
                return .none
            case .updateToolTipState:
                state.isToolTipPresented = false
                return .none
            default:
                return .none
            }
        }
    }
}
